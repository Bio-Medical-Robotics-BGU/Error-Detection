function [StatisticsTable2] = RM_Model(T)

Factor1 = 'Shift';
Factor2 = 'Session';

%Coding columns conditions for within design
WithinDesign = table([1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6]',[1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3]','VariableNames',{ Factor1, Factor2});
WithinDesign.(Factor1) = categorical(WithinDesign.(Factor1));
WithinDesign.(Factor2) = categorical(WithinDesign.(Factor2));

%Fiting repeated measures model and perform tests
%fitrm - for the repeated measures design
RepeatedMeasuresModel1 = fitrm(T,'Shift1SessionA-Shift6SessionC ~ 1	','WithinDesign',WithinDesign);
[StatisticsTable,A,C]= ranova(RepeatedMeasuresModel1,'WithinModel',[Factor1,'*',Factor2]);
MauchlyTable = mauchly(RepeatedMeasuresModel1,C);% testingsphericity
EpsilonTable = epsilon(RepeatedMeasuresModel1,C);
MauchlyAndEpsilonTable = [MauchlyTable,EpsilonTable];  % significant means need to fix df and then recalculate the p value
EffectNames = {Factor1,Factor2,[Factor1,':',Factor2]};
MauchlyAndEpsilonTable.Properties.RowNames = [{'.'},EffectNames];

%SphericityCorrection
IsSphericityCorrectionNeeded=cell(height(StatisticsTable),1);
CorrectedDFGG = (nan(height(StatisticsTable),1));
CorrectedDFHF = (nan(height(StatisticsTable),1));

for iEffect = 1:length(EffectNames)
    CurEffect  = EffectNames{iEffect};

    CurEffectMauchlyAndEpsilon =  MauchlyAndEpsilonTable(CurEffect,:);
    if CurEffectMauchlyAndEpsilon.DF>0 %only for relevant factors
        CurEffectMauchlyAndEpsilon.pValue;
        CurrEffectAlphaGG = CurEffectMauchlyAndEpsilon.GreenhouseGeisser;
        CurrEffectAlphaHF = CurEffectMauchlyAndEpsilon.HuynhFeldt;

        if CurEffectMauchlyAndEpsilon.pValue<0.05 %Significant - correction is needed
            IsSphericityCorrectionNeeded{strcmp(['(Intercept):',CurEffect],StatisticsTable.Row)} ='yes';
            CorrectedDFGG(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row)) = CurrEffectAlphaGG*StatisticsTable.DF(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row));
            CorrectedDFGG(find(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row))+1) = CurrEffectAlphaGG*StatisticsTable.DF(find(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row))+1);
            CorrectedDFHF(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row)) = CurrEffectAlphaHF*StatisticsTable.DF(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row));
            CorrectedDFHF(find(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row))+1) = CurrEffectAlphaHF*StatisticsTable.DF(find(strcmp(['(Intercept):',CurEffect],StatisticsTable.Row))+1);

        else
            IsSphericityCorrectionNeeded{strcmp(['(Intercept):',CurEffect],StatisticsTable.Row)} ='no';
        end
    end
end
StatisticsTable1 = [StatisticsTable, table(IsSphericityCorrectionNeeded),table(CorrectedDFGG),table(CorrectedDFHF)];

StatisticsTable2 = [];
for RowNum  = [3,5,7]
    RowName = StatisticsTable1.Row(RowNum);
    F = StatisticsTable1.F(RowNum);
    if strcmp(StatisticsTable1.IsSphericityCorrectionNeeded(RowNum),'yes') %if we need to correct the df and p values
        df1 = StatisticsTable1.CorrectedDFGG(RowNum);
        df2=StatisticsTable1.CorrectedDFGG(RowNum+1);
        p = StatisticsTable1.pValueGG(RowNum);

    else %no correction needed
        df1 = StatisticsTable1.DF(RowNum);
        df2=StatisticsTable1.DF(RowNum+1);
        p = StatisticsTable1.pValue(RowNum);
    end
    TestP = 1-fcdf(F,df1,df2);
    if abs(p-TestP)>1e-10
        errordlg('Check p value!')
    end

    AddToTable=table(F,df1,df2,p,'RowNames',RowName);
    StatisticsTable2 = [StatisticsTable2;AddToTable];

end
StatisticsTable2 = round(StatisticsTable2,3);
end