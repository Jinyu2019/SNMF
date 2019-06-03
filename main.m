clc
clear all
% run 'simulated_data_2.m' to produce inputdata.mat
load inputdata.mat
% to get robust results, repeatly run SNMF algorithm for 'nrepeat' times.
nrepeat = 5;
n = size(A,1);
ntype = size(A,3);
k = parameters.K;
results.H = zeros(n,k,nrepeat);
results.S = zeros(k,k,ntype,nrepeat);
results.objval = cell(nrepeat,1);

for irepeat = 1:nrepeat
    [H, S, objval] = SNMF(A, W, parameters);
    results.H(:,:,irepeat) = H;
    results.S(:,:,:,irepeat) = S;
    results.objval{irepeat} = objval;
    
    % HeatMap(H*H','Standardize','none')
    % HeatMap(H,'Standardize','none')
    figure(irepeat)
    subplot(1,2,1)
    imagesc(H)
    title(['H (irepeat = ' num2str(irepeat) ')'],'FontSize',12)
    ylabel('Sample','FontSize',12)
    xlabel('Cluster','FontSize',12)
    
    subplot(1,2,2)
    plot(1:size(objval,1),objval(:,7),'-*')
    title(['Objective values (irepeat = ' num2str(irepeat) ')'],'FontSize',12)
    xlabel('Iteration','FontSize',12)
    ylabel('Value','FontSize',12)
    set(gca,'XTick',[1:50:size(objval,1),size(objval,1)],...
        'XTickLabel',[1:50:size(objval,1),size(objval,1)])
    clear H S objval
end

%% obtain the cluster members
cM = compute_cluster(results.H);
cM(cM<0.5) = 0;
predictIdx = kmeans(cM,k,'distance','sqEuclidean');
figure(nrepeat+4)
plot(1:length(predictIdx),predictIdx,'*')
title('Clustering','FontSize',12)
xlabel('Sample','FontSize',12)
ylabel('Cluster index','FontSize',12)
set(gca,'XTick',[1,40,70,90,120],'XTickLabel',[1,40,70,90,120])
set(gca,'YTick',0:k,'YTickLabel',0:k)

% HeatMap(cM,'Standardize','none')
% cgoGB = clustergram(cM,'Standardize','none');
figure(nrepeat+5);
imagesc(cM)
title('Consensus clustering','FontSize',12)
xlabel('Sample','FontSize',12)
ylabel('Sample','FontSize',12)
set(gca,'XTick',[1,40,70,90,120],'XTickLabel',[1,40,70,90,120])
set(gca,'YTick',[1,40,70,90,120],'YTickLabel',[1,40,70,90,120])
%% evaluate the clusters comparing with real ones.
trueIdx = zeros(n,1);
for ik = 1:k
    trueIdx(realClusters{ik}) = ik;
end
[purity, NMI, ARI] = compare_cluster(trueIdx,predictIdx)

%% save results
save SNMF_results.mat results cM purity NMI ARI trueIdx predictIdx
% close all