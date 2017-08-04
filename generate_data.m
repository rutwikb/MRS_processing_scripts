function y= generate_data(dcm1_path,dcm2_path,moveout_path)

%if files do not need to be renamed, skip the renaming loop above
new_seven_files = dir('*.7');

%cycle over the .7 files
for q=1:length(new_seven_files)
    np= new_seven_files(q).name;
    
    %create the path for the pfile
    p_path = fullfile(pwd,np);
    
    cd(dcm2_path);
    
    D3 = dir;
    for j = 3:length(D3)
        %counter;
        dcm2_sub = D3(j).name;
        %counter = counter+1;
        
        %add the subfolders in dcmdir 2 to path
        dcm2_sub_path = fullfile(pwd,dcm2_sub);
        
        fprintf('the path to p_file is is: %s\n',p_path);
        
        fprintf('the path to dcmdir 2 is: %s\n',dcm2_sub_path);
        
        %run the main scripts that create the nifti files--------------
        
        %generate the mask nifti files
        MRS_struct = GannetLoad({p_path});
        MRS_struct = GannetMask_GE(p_path,dcm1_path,MRS_struct,dcm2_sub_path,1);
        
        
        %save the output image for QC purposes. This figure extraction
        %tool uses a third party function called export_fig, which can
        %be found in a separate folder. Refer to the readme doc for
        %more information
        export_fig( gcf, ...      % figure handle
            np,... % name of output file without extension
            '-painters', ...      % renderer
            '-jpg', ...           % file format
            '-r72' );             % resolution in dpi
        %--------------------------------------------------------------
        
        %move the subdirectory of dcmdir2 to a different folder so it
        %doesn't interfere with the next iteration of the loop
        movefile (D3(j).name, moveout_path)
        
        %since at the beginning of the loop we changed to dcmdir2, at
        %the end we must change back to the parent directory
        cd ..
        %need to break the inner loop so the program only checks the
        %first file that is in the dcmdir2 folder
        break
        
    end % end of loop that loops over subdir in dcmdir2
    
end %end of loop that loops over the .7 files in each subjects folder

end %end of the function

