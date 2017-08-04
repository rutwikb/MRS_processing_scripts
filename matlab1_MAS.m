% /scratch/rutwik/MAS/dataset_sim
% /archive/data-2.0/STOPPD/data/nii
%% Getting path to subjects directory
prompt = 'Enter the path of folder where all subjects are located: ';
N = 100;
for t=1:N
    str = input(prompt,'s');
    if ~isempty(str)
        %change directories into the parent folder
        cd(str);
        break;
    end
end
%% Get the path to the nifti folder
prompt2 = 'Enter the path of the folder containing nifti files: ';
M = 100;
for u=1:M
    str2 = input(prompt2,'s');
    if ~isempty(str2)
        %the folder of nifti files is now stored in str2
        break;
    end
end

%% The other stuff
D = dir;

%outer loop that goes over all subject folders
for i = 3:length(D)
    %% Adjusting the naming convention
    
    % %     %change directories into each subject's folder
    % %     current = fullfile(pwd,D(i).name);
    
    %get the subject id
    name_split = strsplit(D(i).name,'_');
    
    tf = strcmp(name_split(1),'Rothschild');
    
    truncated = [name_split(1), name_split(2), name_split(3),name_split(4)];
    adjusted_name = strjoin(truncated,{'_','_','_'});
   
    
    newdir = sprintf('%s_%s','MRS',adjusted_name);
    mkdir(newdir);
    movefile(D(i).name,newdir);
    
    
    %drop the last part of the file name
    %% Importing the nifti file
    %identify subject's nifti folder
    
    half_path = fullfile(str2,adjusted_name);
    final = fullfile(half_path,'/**T1**nii*');
    new_struct= rdir(final);
    
    try
    nifti = new_struct(1).name;
    
    %unzip the nifti file
    gunzip(nifti,newdir);
    cd(newdir);
    local_dir = dir('*.nii');
    local_nifti = local_dir.name;
    %% Processing the spar files
    %get the spar file for each ROI
    spar_files = dir('*.SPAR');
    
    for k=1:length(spar_files)
        
        
        current_spar = spar_files(k).name;
        splitname = strsplit(current_spar,'_');
        ROI_name = splitname(8);
        %don't know why there are 2 spar files for each ROI but the ones that have are labelled ref do not produce a good MRS result and the
        %ones that have 'act' in the label do.
        act = splitname(12) ;
        is_act = strcmp (act,'act.SPAR');
        is_SACC = strcmp(ROI_name,'SACC');
        is_DLPFC = strcmp(ROI_name,'LTDIPFC');
        ROI_char = splitname{8};
        
        if is_act==1 && is_SACC==1
            %gannetmask here
            GannetMask_Philips(current_spar,local_nifti);
            
            %save the output image for QC purposes. This figure extraction
            %tool uses a third party function called export_fig, which can
            %be found in a separate folder. Refer to the readme doc for
            %more information
            export_fig( gcf, ...      % figure handle
                ROI_char,... % name of output file without extension
                '-painters', ...      % renderer
                '-jpg', ...           % file format
                '-r72' );             % resolution in dpi
            %--------------------------------------------------------------
        end
        
        if is_act==1 && is_DLPFC==1
            %gannetmask here
            GannetMask_Philips(current_spar,local_nifti);
            
            export_fig( gcf, ...      % figure handle
                ROI_char,... % name of output file without extension
                '-painters', ...      % renderer
                '-jpg', ...           % file format
                '-r72' );             % resolution in dpi
        end
        
    end
    
    catch
        warning('nifti not available for subject %s\n',adjusted_name);
    end
    
    
    % End of the loop
    cd(str);
end


% % % % GannetMask_Philips('data.SPAR','input.nii');
% % %
% % % for subject_directories in main_directory
% % %   change directories to each subject
% % %
% % %   for files in directory
% % %
% % %       -namesplit by delimiter _ -> grab subject id
% % %       -copy the nifti file from the nii folder
% % %       -if 8th field is LTDIPFC & extension is spar
% % %           run gannetmask_Philips
% % %
% % %           *---->>>need to save the images as jpg
% % %
% % %       -run same procedure for 8th field being SACC
% % %         gannetmask_philips
% % %
% % %
% % %         %this will generate the roi placement images for QC
% % %
% % %      for each spar file, on the first iteration run gannet for sacc
% and the second run for the dlpfc
% % %