function [curr_pos leaf_error, leaf_RMS_error, bank_RMS_error, th_percentile, ...
    bank_th_percentile, mean_leaf_error, variance] = ...
    LeafError(Matrix, zeroincluded, bankA)
% [leaf_error leaf_RMS_error bank_RMS_error th_percentile] = LeafError(Matrix, zeroincluded, bankA)
% 
% onlyzeroincluded = 1 - only the nonzero values are included in the
% calculations
% 
% bankA == 'A' - Matrix is from Bank A, it is important for the leaf_error calculation 
%
% Results are in mm
% 
% 
% RMS CALCULATION
% 
% Leaf error is defined as the difference between the MLC (or collimator, gantry, etc) 
% planned position and the actual position.
%
% Leaf RMS error is a single value that is the root mean square error of an individual leaf, 
% taking into account the leaf error at every point over the course of
% the delivery. Includes leafes if it or the opposite leaf moved during
% the delivery, that is RMS_error ~= 0
%
% Mean leaf error is the mean of the error of a given leaf over the course of the delivery, 
% but takes into account the direction, or sign, of the error and
%
% The 95th percentile error specifically references a single value drawn from the total list of 
% errors captured in the file. The direction of the error does not matter.
% I took the absolute value (?)
%
% Mean, or bank RMS error is the mean of the leaf RMS errors of a given bank (A or B) and treatment delivery
%
%%

% The first value of each group of four is the planned leaf position, then
% comes the true position, then the planned position in the previous shape
% and finally the planned position in the next shape. 

% To get the leaf error, we substract the true position from the
% planned position for Bank A. For Bank B it should be the other
% way around.

Matrix_tmp = Matrix(:, 15:end);

curr_pos = Matrix_tmp(:,2:4:end)./100; % convert to mm
planned_pos = Matrix_tmp(:,1:4:end)./100;

leaf_error = curr_pos - planned_pos;
%%

if zeroincluded == 0
    
    ii = find(Matrix(:,4)==0); % for beam_on
    jj = find(Matrix(:,3)==1); % for beam_hold_off
    
    leaf_error(ii,:) = [];

end
%%    
if bankA == 'B'
    leaf_error = -leaf_error;
%     fprintf('B\n')
else
%     fprintf('A\n')
end



leaf_RMS_error = rms(leaf_error); % in mm


mean_leaf_error = mean(leaf_error); % in mm
    
variance = var(leaf_error)


for kk = 1:60 % 60 MLC leaves         

    
    th_percentile(1,kk) = prctile(abs(leaf_error(:,kk)),95); % in mm


end

bank_th_percentile = prctile(abs(leaf_error(:)),95); % in mm
 




if zeroincluded == 1
    
    bank_RMS_error = mean(nonzeros(leaf_RMS_error)); % in mm
    
elseif zeroincluded == 0
    
    bank_RMS_error = mean(leaf_RMS_error); % in mm
    
    
end
end