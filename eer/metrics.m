function [ACC, EER, FAR, FRR] = metrics(score, test_num, train_num, class_num)
% 功能：计算ACC，EER，FAR（向量），FRR（向量）
% 输出即为计算的结果
% 输入：
%   @score：用算法计算的得分矩阵，每个元素的值在[0,1]，尺寸为[test_num*class_num, train_num*class_num]
%           说明：score的每一行表示一个测试样本，每test_num行为一组，这一组里的测试样本都属于同一类；
%                       每一列表示一个训练样本，每train_num列为一组，这一组里的训练样本都属于同一类
%   @test_num: 测试样本中每类含有样本的个数
%   @train_num: 训练样本中每类含有样本的个数
%   @class_num: 类别数（仅能处理test类和train类数目一样的情况）


    %% 计算Acc（识别率）
    flag = zeros(class_num*test_num, class_num*train_num);
    % 在每一列找到最大值，令flag里对应位置的元素为1
    for testID = 1:class_num*test_num
        [~, id] = max(score(testID, :));
        flag(testID, id) = 1;
    end
    % 计算Acc
    num = 0;
    for sampleID = 1:class_num
        matrix = flag((sampleID-1)*test_num+1:(sampleID-1)*test_num+test_num, (sampleID-1)*train_num+1:(sampleID-1)*train_num+train_num);
        num = num+size(nonzeros(matrix), 1);
    end
    ACC = num/(class_num*test_num);  %确认一下，这里应该是test num吗？

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
        FRR(id) = 1-num/(class_num*test_num*train_num);  %分母是类内的比较次数
        FAR(id) = (sum-num)/(class_num*test_num*class_num*train_num-class_num*test_num*train_num);  %分母是类间比较次数（总比较次数-类内比较次数）
        id = id+1;
    end

    id = 1;
    for id = 1:n
        if (FRR(id) >= FAR(id))
            break;
        end
    end
    EER = (FRR(id)+FAR(id))/2
    %% 画图，看需求
    %figure;
    %plot(FAR,'r');
    %hold on;
    %plot(FRR,'b');
    %legend('FAR','FRR')
end