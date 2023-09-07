function [R] = renderpic( strEDPath, strWorkPath, strExcel, nStart, nRow, bPic )

%����strEDPathΪeidors�İ�װĿ¼
%����strWorkPathΪ��������·��
%����strExcelΪ��ŷ������ݵ�Excel�ļ�
%����nStartΪ������ع�ͼ�ķ������ݵ���ʼ�к�
%����nRowΪ������ع�ͼ�ķ������ݵ�����
%����bPic��ʾ�Ƿ񱣴��ع�ͼ��Ĭ��Ϊ��(0)

warning('off');

%����·������
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

%���EIDORS���л���
run(strEDPath);

%��ʼ������
mElem_data = zeros(1, 576);
m = 1;

%����Բ��ģ�ͺͲ�������ģʽ,�����絼��Ϊ0.15
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