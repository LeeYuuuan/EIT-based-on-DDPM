function [R] = generatedata( strEDPath, strWorkPath, dBkg, dTarget, bHomo, dRad, dGap, bPic )

%����strEDPathΪeidors�İ�װĿ¼
%����strWorkPathΪ��������·��
%����ʹ������Ԫģ��ΪԲ�Ρ�576��Ԫ��16��缫
%ģ������X�᷶Χ(-1 1)��Y�᷶Χ(-1 1)
%ģ�ͼ�������ģʽΪ���������ڽ�����
%ģ�ͱ����絼��Ϊ0.15S/m��ģ��ˮ�۱�����ҺNaCl��Һ�絼��
%ģ���Ŷ�Ŀ��絼�������Ϊ0.70S/m��ģ��ѪҺ�絼��
%����dBkgΪģ�ͱ����絼�ʣ�Ĭ��Ϊ0.15S/m
%����dTargetΪ�Ŷ�Ŀ��絼�ʣ�Ĭ��Ϊ0.70S/m
%����bHomo��ʾ�Ŷ�Ŀ���Ƿ�Ϊ�絼�ʾ��ȷֲ���Ĭ��Ϊ��(0)
%����dRadΪ�Ŷ�Ŀ��뾶��Ĭ��Ϊģ�Ͱ뾶��10%����0.1��
%����dGapΪ�Ŷ�Ŀ����Բ��ģ������X�ᡢY���ƶ�ʱ�ļ����Ĭ��0.02
%����bPic��ʾ�Ƿ񱣴��Ŷ�Ŀ����ģ�͵�ͼ��Ĭ��Ϊ��(0)


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
strOutput = [strWorkPath, 'data.xlsx'];

%���EIDORS���л���
run(strEDPath);

%����Բ��ģ�ͺͲ�������ģʽ,���е���ǿ��
imdl = mk_common_model('c2c2',16);
img = mk_image(imdl, dBkg);
stim = mk_stim_patterns(16, 1, '{op}', '{ad}', {'no_meas_current'}, 1);
img.fwd_model.stimulation = stim;
img.calc_colours.cb_shrink_move = [0.5,0.8,-.10];

%�����Ŷ�Ŀ������λ��
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
        %�ж��Ŷ�Ŀ���Ƿ�λ��Բ��ģ����
        dCenter = [x, y];
        dDistance = norm(dOrigin - dCenter);
        if dDistance < 1 - dRad
            vTargetElem = mk_c2f_circ_mapping(img.fwd_model, [x;y;dRad]);
            %����Ŀ��絼����Ŀ��������޸�Ŀ��絼��
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
             %���߽��ѹ
             vVolt = fwd_solve(img);
             %����Ԫ�絼�ʺͱ߽��ѹ�����ݴ棬���ﵽ1000��ʱת��xlsx�ļ�
             mElem_data(l,:) = img.elem_data';
             mVolt_data(l,:) = vVolt.meas';
             if rem(j, nTh) == 0
                  %����Ԫ�絼�ʺͶ�Ӧ�߽�缫������ѹֵд������ļ�
                  xlswrite(strOutput, mElem_data, 1, ['A', num2str(k)]);
                  xlswrite(strOutput, mVolt_data, 2, ['A', num2str(k)]);
                  mElem_data = [];
                  mVolt_data = [];
                  l = 0;
                  k = j + 1;
             end
             %�����Ŷ�Ŀ���ģ�͵�ͼ��
             if bPic
                 clf;
                 show_fem(img, 1);
                 strPic = [strWorkPath, 'data', num2str(j,'%05d'), '.png'];
                 opts.resolution = 75;
                 print_convert(strPic, opts);
             end
             %��ʾ����
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