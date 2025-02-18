function [adjusted_p] = holm(p, VariableNames, T, MetricName)
%This function calculates adjusted p values for multiple comparisons tests
%I used this reference:
%https://www.jstor.org/stable/2532694

p = p(:);%making p a column vector


[p_sort, SortInd]= sort(p);%sorting p from smallest to highest


[~,IndOrigOrder] = sort(SortInd);%the original order of p elements (for later)


rank = [length(p):-1:1].';%ranking each p value 


ri = rank.*p_sort;%almost adjusted p


%making sure that the values ascending
Dif = [nan ;diff(ri)];
while (sum(Dif<0)) % as long as the values are not ascending
    ri(find(Dif<0))=ri(find(Dif<0)-1);%lower value get the value of the previous value
    Dif = [nan ;diff(ri)];%calculating differences again
end


ri(ri>1)=1;%changing values higher than 1 to 1 


adjusted_p = ri(IndOrigOrder);%back to the original order

%shows the data - want it to be not signficant
figure;
hold on;
for iCondition = 1:length(VariableNames)
    plot(iCondition*ones(height(T),1),T.(VariableNames{iCondition}),'dk')
end
xticklabels(VariableNames)
xtickangle(45)
xlim([0.5 iCondition+0.5])
ylabel(MetricName);
YLIM = ylim;
Ytext = YLIM(2)-0.05*(YLIM(2)-YLIM(1));
text(1:length(VariableNames),Ytext*ones(length(VariableNames),1),(num2str(adjusted_p)),'Color','r')


end