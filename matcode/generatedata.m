function [R] = generatedata( strEDPath, strWorkPath, dBkg, dTarget, bHomo, dRad, dGap, bPic )

%参数strEDPath为eidors的安装目录
%参数strWorkPath为输出结果的路径
%程序使用有限元模型为圆形、576单元、16点电极
%模型坐标X轴范围(-1 1)、Y轴范围(-1 1)
%模型激励测量模式为对向激励、邻近测量
%模型背景电导率为0.15S/m，模拟水槽背景溶液NaCl溶液电导率
%模型扰动目标电导率最大设为0.70S/m，模拟血液电导率
%参数dBkg为模型背景电导率，默认为0.15S/m
%参数dTarget为扰动目标电导率，默认为0.70S/m
%参数bHomo表示扰动目标是否为电导率均匀分布，默认为否(0)
%参数dRad为扰动目标半径，默认为模型半径的10%，即0.1；
%参数dGap为扰动目标在圆形模型中沿X轴、Y轴移动时的间隔，默认0.02
%参数bPic表示是否保存扰动目标与模型的图像，默认为否(0)


warning('off');

%修正路径变量
cCheck = strEDPath(length(strEDPath));
if cCheck ~= '\'
    strEDPath = [strEDPath, '\', 'startup.m'];
else
    strEDPath = [strEDPath, 'startup.m'];
end
cCheck = strWorkPath(length(strWorkPath));
if cCheck ~= '\'
    strWorkPath = [strWorkPath, '\'];
end
strOutput = [strWorkPath, 'data.xlsx'];

%检查EIDORS运行环境
run(strEDPath);

%创建圆形模型和测量激励模式,其中电流强度
imdl = mk_common_model('c2c2',16);
img = mk_image(imdl, dBkg);
stim = mk_stim_patterns(16, 1, '{op}', '{ad}', {'no_meas_current'}, 1);
img.fwd_model.stimulation = stim;
img.calc_colours.cb_shrink_move = [0.5,0.8,-.10];

%遍历扰动目标中心位置
dOrigin = [0, 0];
j = 1;
k = 1;
l = 1;
nTh = 1000;
nCount  = 0;
mElem_data = zeros(nTh, 576);
mVolt_data = zeros(nTh, 192);
for x = -1:dGap:1
    for y = -1:dGap:1
        %判断扰动目标是否位于圆形模型内
        dCenter = [x, y];
        dDistance = norm(dOrigin - dCenter);
        if dDistance < 1 - dRad
            vTargetElem = mk_c2f_circ_mapping(img.fwd_model, [x;y;dRad]);
            %根据目标电导率与目标均匀性修改目标电导率
            [m, n, v] = find(vTargetElem);
            dMax = max(v);
            dMin = min(v);
            for i = 1:length(m)
                if bHomo
                    vTargetElem(m(i),n(i)) = dTarget - dBkg;
                else
                    vTargetElem(m(i),n(i)) = (v(i)-dMin)/(dMax-dMin)*(dTarget-dBkg);
                end
            end
            img.elem_data(:) = dBkg;
            img.elem_data = img.elem_data + vTargetElem(:);
             %求解边界电压
             vVolt = fwd_solve(img);
             %将单元电导率和边界电压数据暂存，当达到1000项时转存xlsx文件
             mElem_data(l,:) = img.elem_data';
             mVolt_data(l,:) = vVolt.meas';
             if rem(j, nTh) == 0
                  %将单元电导率和对应边界电极测量电压值写入输出文件
                  xlswrite(strOutput, mElem_data, 1, ['A', num2str(k)]);
                  xlswrite(strOutput, mVolt_data, 2, ['A', num2str(k)]);
                  mElem_data = [];
                  mVolt_data = [];
                  l = 0;
                  k = j + 1;
             end
             %保存扰动目标和模型的图像
             if bPic
                 clf;
                 show_fem(img, 1);
                 strPic = [strWorkPath, 'data', num2str(j,'%05d'), '.png'];
                 opts.resolution = 75;
                 print_convert(strPic, opts);
             end
             %显示计数
             fprintf(1, repmat('\b', 1, nCount));
             nCount = fprintf(1, 'Complete %d', j);
             l = l + 1;
             j = j + 1;
        end
    end
end

if rem(j, nTh) ~= 0
    xlswrite(strOutput, mElem_data, 1, ['A', num2str(k)]);
    xlswrite(strOutput, mVolt_data, 2, ['A', num2str(k)]);
end

warning('on');

fprintf(1, '\n');
R = 'OK!';

end