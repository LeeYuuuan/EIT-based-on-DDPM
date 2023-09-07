
%%%%====================Hyperpramaters=================%%%%
EIDORS_PATH = 'D:\EITMat\eidors-v3.10\eidors';
RESULT_PATH = 'D:\EITMat\DiffusionData';
PIC_PATH = 'D:\EITMat\DiffusionData\pics\';
flag = 0;
%参数background_conductivity为模型背景电导率，默认为0.15S/m
background_conductivity = 0.15;
%参数target_radius为扰动目标半径，默认为模型半径的10%，即0.1；
%参数sampling_gap为扰动目标在圆形模型中沿X轴、Y轴移动时的间隔，默认0.02
target_radius = 0.1;
sampling_gap = 0.02;

%参数target_conductivityt为扰动目标电导率，默认为0.70S/m
%参数bHomo表示扰动目标是否为电导率均匀分布，默认为否(0)
target_conductivity = 0.70;
bHomo = 0;

%%%%====================Run eidors=================%%%%
warning('off');
if EIDORS_PATH(length(EIDORS_PATH)) ~= '\'
    EIDORS_PATH = [EIDORS_PATH, '\', 'startup.m'];
else
    EIDORS_PATH = [EIDORS_PATH, 'startup.m'];
end
run(EIDORS_PATH)


%%%%====================Create Models=================%%%%
%stimulation pattern
stim = mk_stim_patterns(16, 1, '{op}', '{ad}', {'no_meas_current'}, 1);

% Create circle model
cir_mdl = mk_common_model('d2C',16);
% show_fem(cir_mdl.fwd_model)

% circle image
cir_img = mk_image(cir_mdl, background_conductivity);
cir_img.fwd_model.stimulation = stim;
cir_img.calc_colours.cb_shrink_move = [0.5,0.8,-.10];
% show_fem(cir_img);

% calculate voltages
vh = fwd_solve(cir_img);


% Create grid model
% 32 * 32
grid{1}= linspace(-1,1,33); % x grid
grid{2}= linspace(-1,1,33); % y grid
gri_mdl = mk_grid_model(cir_mdl.fwd_model,grid{:});
% show_fem(gri_mdl)

% grid image
gri_img = mk_image(gri_mdl, background_conductivity);
gri_img.fwd_model.stimulation = stim;
gri_img.calc_colours.cb_shrink_move = [0.5,0.8,-.10];
% show_fem(gri_img)

%%%%====================Traverse Target Center=================%%%%
Origin = [0, 0];


nTh = 1000;
nCount  = 0;
target_elem_data = zeros(1, 1024); % save trangle element conductivities
target_hpixel_data = zeros(1, 2048); % save pixel conductivities
target_voltage_data = zeros(1, 192); % save boundry voltages
count_data = zeros(1, 1);

count_of_set = 1;
count = 1;

bHomo = 0;
for target_conductivity = 0.1:0.1:1
for target_radius = 0.1:0.1:0.3
for x = -1:sampling_gap:1
    for y = -1:sampling_gap:1
        
        target_center = [x, y];
        distance = norm(Origin - target_center);
        if distance < 1 - target_radius

            % for circle model
            vTargetElem = mk_c2f_circ_mapping(cir_img.fwd_model, [x;y;target_radius]);
            [m, n, v] = find(vTargetElem);
            dMax = max(v);
            dMin = min(v);
            for i = 1:length(m)
                if bHomo
                    vTargetElem(m(i),n(i)) = target_conductivity - background_conductivity;
                else
                    vTargetElem(m(i),n(i)) = (v(i)-dMin)/(dMax-dMin)*(target_conductivity- background_conductivity);
                end
            end
            cir_img.elem_data(:) = background_conductivity;
            cir_img.elem_data = cir_img.elem_data + vTargetElem(:);

            % for grid model
            gvTargetElem = mk_c2f_circ_mapping(gri_img.fwd_model, [x;y;target_radius]);
            [m, n, v] = find(gvTargetElem);
            dMax = max(v);
            dMin = min(v);
            for i = 1:length(m)
                if bHomo
                    gvTargetElem(m(i),n(i)) = target_conductivity - background_conductivity;
                else
                    gvTargetElem(m(i),n(i)) = (v(i)-dMin)/(dMax-dMin)*(target_conductivity- background_conductivity);
                end
            end
            gri_img.elem_data(:) = background_conductivity;
            gri_img.elem_data = gri_img.elem_data + gvTargetElem(:);
            
            %calculate boundary voltages
            vVolt = fwd_solve(cir_img);
            target_elem_data(count,:) = cir_img.elem_data';
            target_hpixel_data(count,:) = gri_img.elem_data';
            target_voltage_data(count,:) = vVolt.meas';

            count = count + 1;
            
            if rem(count, 100) == 0
                disp(['current index:',num2str(count)]);
            end

%             clf;
%             show_fem(gri_img, 1);
%             strPic = [PIC_PATH, '/grid/gri_', num2str(count,'%05d'), '.png'];
%             opts.resolution = 75;
%             print_convert(strPic, opts);
%             
%             clf;
%             show_fem(cir_img, 1);
%             strPic = [PIC_PATH, '/circle/cir_', num2str(count,'%05d'), '.png'];
%             opts.resolution = 75;
%             print_convert(strPic, opts);
            
            % reset element conductivity to background cond.
            cir_img.elem_data(:) = background_conductivity;
            gri_img.elem_data(:) = background_conductivity;

%             if count == 300
%                 flag = 1;
%                 break;
%             end

        end

    end

%     if flag == 1
%         break;
%     end
end
current_state = ['\cond=', num2str(target_conductivity,3), 'radius=', num2str(target_radius,3)];
save([RESULT_PATH, current_state, '_target_elem_data.mat'], "target_elem_data");
save([RESULT_PATH, current_state, '_target_hpixel_data.mat'], "target_hpixel_data");
save([RESULT_PATH, current_state, '_target_voltage_data.mat'], "target_voltage_data");
count_data(count_of_set, 1) = count;
count_of_set = count_of_set + 1;
count = 1;

target_elem_data = zeros(1, 1024); % save trangle element conductivities
target_hpixel_data = zeros(1, 2048); % save pixel conductivities
target_voltage_data = zeros(1, 192); % save boundry voltages


end
end    


    