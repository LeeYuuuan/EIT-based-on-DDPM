function [R] = renderpic( strEDPath, strWorkPath, strExcel, nStart, nRow, bPic )

%参数strEDPath为eidors的安装目录
%参数strWorkPath为输出结果的路径
%参数strExcel为存放仿真数据的Excel文件
%参数nStart为需绘制重构图的仿真数据的起始行号
%参数nRow为需绘制重构图的仿真数据的行数
%参数bPic表示是否保存重构图，默认为否(0)

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
strInput = [strWorkPath, strExcel];
strFileName = strsplit(strExcel, '.');
strPicName = strFileName{1};

%检查EIDORS运行环境
run(strEDPath);

%初始化变量
mElem_data = zeros(1, 576);
m = 1;

%创建圆形模型和测量激励模式,背景电导率为0.15
imdl = mk_common_model('c2c2',16);
img = mk_image(imdl, 0.15);
stim = mk_stim_patterns(16, 1, '{op}', '{ad}', {'no_meas_current'}, 1);
img.fwd_model.stimulation = stim;
img.calc_colours.cb_shrink_move = [0.5,0.8,-.10];

for n = nStart : nStart+nRow-1
    mElem_data = xlsread(strInput, 1, ['A', num2str(n), ':', 'VD', num2str(n)]);
    img.elem_data = mElem_data';
    clf;
    show_fem(img, 1);
    if bPic
        strPic = [strWorkPath, strPicName, num2str(m,'%05d'), '.png'];
        opts.resolution = 75;
        print_convert(strPic, opts);
    end
    m = m + 1;
end

warning('on');

R = 'OK!';

end