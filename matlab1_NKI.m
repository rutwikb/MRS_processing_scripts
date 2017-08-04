%% Subject folder location
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
%% Processing
D = dir;
p=1;
for i = 3:length(D)
    %% Create subfolders for all subjects so data isn't all in one big folder
    
    name_split = strsplit(D(i).name,'_');
    
    truncated = [name_split(1), name_split(2), name_split(3),name_split(4)];
    adjusted_name = strjoin(truncated,{'_','_','_'});
    
    newdir = sprintf('%s_%s','MRS',adjusted_name);
    mkdir(newdir)
    movefile (D(i).name, newdir)
    %% Get the nifti file
    half_path = fullfile(str2,adjusted_name);
    final = fullfile(half_path,'/**T1**nii*');
    
    new_struct= rdir(final);
  
   %% try & catch statements to check for nifti file
        try
        nifti = new_struct(1).name;
        
        %unzip the nifti file
        gunzip(nifti,newdir);
        cd(newdir);
        local_dir = dir('*mprage.nii');
        local_nifti = local_dir.name;
        
        rda_files = dir('*.rda');
        %%
        for k=p:length(rda_files)
            
            
            current_rda = rda_files(k).name;
            splitname = strsplit(current_rda,'_');
            ROI_name = splitname(6);
            
            is_SACC = strcmp(ROI_name,'SACC.rda');
            is_DLPFC = strcmp(ROI_name,'DLPFC.rda');
            ROI_char = splitname{6};
            
            GannetMask_Siemens(current_rda,local_nifti);
            
            
            export_fig( gcf, ...      % figure handle
                ROI_char,... % name of output file without extension
                '-painters', ...      % renderer
                '-jpg', ...           % file format
                '-r72' );             % resolution in dpi
            
        end
        
        %p is the counter that ensures both the dlpfc and the sacc get read
        p = p+1;
        %if p is 3 that means it has already read dlpfc and sacc for a subj,
        %so it can be reset now
        if p ==3
            p =1;
        end
        
    catch
        warning('nifti not available for subject %s\n', adjusted_name);
    end
    
    %continue script
    cd(str)
end
