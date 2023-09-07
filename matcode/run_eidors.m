EIDORS_PATH = 'D:\EITMat\eidors-v3.10\eidors';
% RESULT_PATH = 'D:\EITMat\Data';

warning('off');
if EIDORS_PATH(length(EIDORS_PATH)) ~= '\'
    EIDORS_PATH = [EIDORS_PATH, '\', 'startup.m'];
else
    EIDORS_PATH = [EIDORS_PATH, 'startup.m'];
end

% run eidors
run(EIDORS_PATH);
clc
clear EIDORS_PATH;