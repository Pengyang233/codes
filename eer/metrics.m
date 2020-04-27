function [ACC, EER, FAR, FRR] = metrics(score, test_num, train_num, class_num)
% ���ܣ�����ACC��EER��FAR����������FRR��������
% �����Ϊ����Ľ��
% ���룺
%   @score�����㷨����ĵ÷־���ÿ��Ԫ�ص�ֵ��[0,1]���ߴ�Ϊ[test_num*class_num, train_num*class_num]
%           ˵����score��ÿһ�б�ʾһ������������ÿtest_num��Ϊһ�飬��һ����Ĳ�������������ͬһ�ࣻ
%                       ÿһ�б�ʾһ��ѵ��������ÿtrain_num��Ϊһ�飬��һ�����ѵ������������ͬһ��
%   @test_num: ����������ÿ�ຬ�������ĸ���
%   @train_num: ѵ��������ÿ�ຬ�������ĸ���
%   @class_num: ����������ܴ���test���train����Ŀһ���������


    %% ����Acc��ʶ���ʣ�
    flag = zeros(class_num*test_num, class_num*train_num);
    % ��ÿһ���ҵ����ֵ����flag���Ӧλ�õ�Ԫ��Ϊ1
    for testID = 1:class_num*test_num
        [~, id] = max(score(testID, :));
        flag(testID, id) = 1;
    end
    % ����Acc
    num = 0;
    for sampleID = 1:class_num
        matrix = flag((sampleID-1)*test_num+1:(sampleID-1)*test_num+test_num, (sampleID-1)*train_num+1:(sampleID-1)*train_num+train_num);
        num = num+size(nonzeros(matrix), 1);
    end
    ACC = num/(class_num*test_num);  %ȷ��һ�£�����Ӧ����test num��

    %% Calculate EER
    s = 0;
    e = 1;
    step = 0.0001;
    n = (e-s)/step+1;
    FRR = zeros(n, 1);
    FAR = zeros(n, 1);
    id = 1;
    for th = s:step:e
        flag1 = score>=th;
        sum = size(nonzeros(flag1), 1);
        num = 0;
        for sampleID = 1:class_num
            matrix = flag1((sampleID-1)*test_num+1:(sampleID-1)*test_num+test_num, (sampleID-1)*train_num+1:(sampleID-1)*train_num+train_num);
            num = num+size(nonzeros(matrix), 1);
        end
        FRR(id) = 1-num/(class_num*test_num*train_num);  %��ĸ�����ڵıȽϴ���
        FAR(id) = (sum-num)/(class_num*test_num*class_num*train_num-class_num*test_num*train_num);  %��ĸ�����Ƚϴ������ܱȽϴ���-���ڱȽϴ�����
        id = id+1;
    end

    id = 1;
    for id = 1:n
        if (FRR(id) >= FAR(id))
            break;
        end
    end
    EER = (FRR(id)+FAR(id))/2
    %% ��ͼ��������
    %figure;
    %plot(FAR,'r');
    %hold on;
    %plot(FRR,'b');
    %legend('FAR','FRR')
end