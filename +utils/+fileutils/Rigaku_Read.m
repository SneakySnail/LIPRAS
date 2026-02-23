function data = Rigaku_Read(filename, ext)
%RIGAKU_READ Read Rigaku text exports (.asc, .ras) into a standard struct.
%
%   data = Rigaku_Read(filename, ext)
%
% Fields returned (as available):
%   data.two_theta   row vector
%   data.data_fit    row vector (intensity)
%   data.mult        row vector or scalar (multiplier, if present)
%   data.KAlpha1     scalar (NaN if missing)
%   data.KAlpha2     scalar (NaN if missing)
%   data.scanType    string ("" if missing)
%   data.ext         extension (char)
%
% Notes:
%   * For .asc: looks for *COUNT then reads a single column of counts.
%     twotheta is reconstructed from *START/*STOP and number of points.
%   * For .ras: looks for *RAS_INT_START then reads numeric columns.
%     If a 3rd column exists, it is treated as multiplier and applied.

filename = string(filename);
ext = lower(string(ext));

fid = fopen(filename, 'rt');   % text mode
if fid < 0
    error("Rigaku_Read:FileOpen", "Cannot open file: %s", filename);
end
c = onCleanup(@() fclose(fid)); %#ok<NASGU>  % always close

% ---- defaults (avoid undefined variables)
scanType = "";
kalpha1  = NaN;
kalpha2  = NaN;

startVal = NaN;
stopVal  = NaN;
stepVal  = NaN;

twotheta  = [];
intensity = [];
mult      = 1;

if ext == ".asc"
    % ------------------------------------------------------------
    % ASC: scan header until *COUNT
    % ------------------------------------------------------------
    while true
        line = fgetl(fid);
        if ~ischar(line)
            error("Rigaku_Read:ASCHeader", "EOF before *COUNT in %s", filename);
        end

        s = strtrim(string(line));
        if s == ""
            continue
        end

        tok = split(s);
        key = tok(1);

        if key == "*COUNT"
            break
        elseif key == "*SCAN_MODE" && numel(tok) >= 3
            scanType = tok(3);
        elseif key == "*WAVE_LENGTH1" && numel(tok) >= 3
            kalpha1 = str2double(tok(3));
        elseif key == "*WAVE_LENGTH2" && numel(tok) >= 3
            kalpha2 = str2double(tok(3));
        elseif key == "*START" && numel(tok) >= 3
            startVal = str2double(tok(3));
        elseif key == "*STOP" && numel(tok) >= 3
            stopVal = str2double(tok(3));
        elseif key == "*STEP" && numel(tok) >= 3
            stepVal = str2double(tok(3));
        end
    end

    % After *COUNT, many exports list one number per line, sometimes comma separated
    C = textscan(fid, '%f', ...
        'Delimiter', {',',' ','\t'}, ...
        'MultipleDelimsAsOne', true);

    intensity = C{1}.';
    if isempty(intensity)
        error("Rigaku_Read:ASCData", "No numeric intensity data after *COUNT in %s", filename);
    end

    nPoints = numel(intensity);

    % Reconstruct axis robustly
    if isfinite(startVal) && isfinite(stopVal)
        twotheta = linspace(startVal, stopVal, nPoints);
    elseif isfinite(startVal) && isfinite(stepVal)
        twotheta = startVal + (0:nPoints-1) * stepVal;
        stopVal = twotheta(end);
    else
        error("Rigaku_Read:ASCAxis", "Missing START/STOP/STEP in %s", filename);
    end

    mult = 1;

elseif ext == ".ras"
    % ------------------------------------------------------------
    % RAS: scan header until *RAS_INT_START, pick off metadata
    % ------------------------------------------------------------
    while true
        line = fgetl(fid);
        if ~ischar(line)
            error("Rigaku_Read:RASHeader", "EOF before *RAS_INT_START in %s", filename);
        end

        s = strtrim(string(line));
        if s == ""
            continue
        end

        if strcmpi(s, "*RAS_INT_START")
            break
        end

        % Typical forms:
        %   *ALPHA1 "1.540593"
        %   *ALPHA2 "1.544414"
        %   *MEAS_SCAN_AXIS_X "2THETA"
        if contains(s, "ALPHA1", "IgnoreCase", true)
            parts = split(s);
            if numel(parts) >= 2
                kalpha1 = str2double(erase(parts(2), '"'));
            end
        elseif contains(s, "ALPHA2", "IgnoreCase", true)
            parts = split(s);
            if numel(parts) >= 2
                kalpha2 = str2double(erase(parts(2), '"'));
            end
        elseif contains(s, "MEAS_SCAN_AXIS_X", "IgnoreCase", true)
            parts = split(s);
            if numel(parts) >= 2
                scanType = erase(parts(2), '"');
            end
        end
    end

    % ------------------------------------------------------------
    % Numeric block. Many RAS files end the block with *RAS_INT_END.
    % We'll read line-by-line so we can stop cleanly.
    % Accept either 2 cols (x y) or 3 cols (x y mult).
    % ------------------------------------------------------------
    x = zeros(1,0);
    y = zeros(1,0);
    m = zeros(1,0);

    while true
        pos = ftell(fid);
        line = fgetl(fid);
        if ~ischar(line)
            break
        end

        s = strtrim(string(line));
        if s == ""
            continue
        end
        if startsWith(s, "*", "IgnoreCase", true)
            % hit footer tag like *RAS_INT_END, stop
            break
        end

        vals = sscanf(char(s), '%f');
        if numel(vals) < 2
            % not numeric; ignore
            continue
        end

        x(end+1) = vals(1); %#ok<AGROW>
        y(end+1) = vals(2); %#ok<AGROW>
        if numel(vals) >= 3
            m(end+1) = vals(3); %#ok<AGROW>
        else
            m(end+1) = 1; %#ok<AGROW>
        end
    end

    if isempty(x)
        % Rewind and fall back to fscanf just in case the file is purely numeric
        fseek(fid, pos, 'bof');
        A = fscanf(fid, '%f', [3 inf]);
        if isempty(A) || size(A,1) < 2
            error("Rigaku_Read:RASData", "No numeric XY data found after *RAS_INT_START in %s", filename);
        end
        twotheta  = A(1,:);
        intensity = A(2,:);
        if size(A,1) >= 3
            mult = A(3,:);
            intensity = intensity .* mult;
        else
            mult = 1;
        end
    else
        twotheta  = x;
        mult      = m;
        intensity = y .* mult;
    end

else
    error("Rigaku_Read:UnsupportedExt", "Unsupported extension '%s' (expected .asc or .ras).", ext);
end

% ---- package output
data = struct( ...
    'KAlpha1', kalpha1, ...
    'KAlpha2', kalpha2, ...
    'two_theta', twotheta, ...
    'data_fit', intensity, ...
    'mult', mult, ...
    'ext', char(ext), ...
    'scanType', scanType );
end