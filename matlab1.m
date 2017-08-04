
%the path below should be a folder that contains all your subjects -> the
%output from the bash scripts that was run before.
prompt = 'Enter the path of the results folder (same as the one from before): ';
N=100;
for t=1:N
   str = input(prompt,'s');
    
   if ~isempty(str)
      cd(str);  
      % previously: cd '/projects/rutwik/2017/STOP-PD/new_tests/unsure_visual_qc/permutation_2/';
      break;    
   end
end


%ensure that the path above and the one at the end of this file match
D = dir;

%use counters to ensure numbers are correct, these are optional
num = 0;
counter =1;

%outer for loop that loops through the output_STOPPD... subject folders
for i = 3:length(D)
    
    %current = D(i).name;
    
    current = fullfile(pwd,D(i).name);
    num = num + 1;
    cd(current);
    
    %find the path to important directories--------------------------------
    
    dcm1_path = fullfile(pwd,'dcmdir1');
    fprintf('the path to dcmdir 1 is: %s\n',dcm1_path);
    
    %this path is not the final path, as there are subfolders in dcmdir2
    dcm2_path = fullfile(pwd,'dcmdir2');
    % fprintf('the path to dcmdir 2 is: %s\n',dcm2_path)
    
    %the moveout path is where the subfolders from dcmdir2 will get copied
    %once they are read, this prevents them interfering with the other
    %subfolders in that directory
    moveout_path = fullfile(pwd,'from_matlab');
    % fprintf('the path to move out is: %s\n',moveout_path)
    
    
    %-------------------------------------------------------------------------
    %renaming loop ( this happens if the program detects that the folders
    %need to be renamed) otherwise it is skipped
    try
        
        %getting the list of the .7 files in the current directory
        seven_files = dir('*.7');
        
        for k=1:length(seven_files)
            np= seven_files(k).name;
            
            %need to rename the header and the .7 file to P##### format, the
            %line below finds the corresponding header file
            corresponding_header= strcat(np,'.hdr');
            
            
            %changes to the .7 & the header files
            %----------------------------------------------------------
            %have to split by delimiter to maintain correct naming convention
            adjusted_np= strsplit(np,'_');
            wanted_file = adjusted_np(3);
            %convert from cell to numeric matrix
            final_7 =  cell2mat(wanted_file);
            
            %do the same thing for headers
            corrected_header = strcat(final_7,'.hdr');
            %----------------------------------------------------------
            
            %rename the .7 file to the correct P#####.7 format
            movefile( np, final_7 );
            
            %rename the .hdr file to correct format;
            movefile( corresponding_header, corrected_header);
            
            
            
        end %renaming loop
        
        generate_data(dcm1_path,dcm2_path,moveout_path)        
    
    catch
        generate_data(dcm1_path,dcm2_path,moveout_path)        
    end
    
    %--------------------------------------------------------------------------
    
    
    %before going to the next subject, move the files from dcmdir 1 to
    %dcmdir 2 because that's where all the outputs are stored
    
    cd(dcm1_path);
    nifti_files = dir('*.nii');
    for m=1:length(nifti_files)
        movefile (nifti_files(m).name, dcm2_path)
    end
    
    %change directories to the same one that contains all subject folders
    cd(str);
    
end %end of loop that goes through all subjects in a folder

