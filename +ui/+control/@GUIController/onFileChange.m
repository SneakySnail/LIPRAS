function this = onFileChange(this, profiles)
% Executes when the current file number changes.
handles = this.hg;
filenum = this.CurrentFile;

plottitle = [num2str(filenum) ' of ' num2str(profiles.getNumFiles)];
set(handles.text_filenum, 'String', plottitle);
set(handles.listbox_files, 'Value', filenum);
end