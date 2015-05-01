% Run Python From Matlab


python('DatPy.py');


f = fopen('expected.dat') ;

s = textscan(f,'%s','Delimiter','[ ]','MultipleDelimsAsOne',true) ;

fclose(f) ;


expected = numel(s{1}) ;

v = NaN(expected,1) ;

for ii = 1:expected

v(ii) = sscanf(s{1}{ii},'%f') ;

end

expected = reshape(v,137,[])' ;


f = fopen('actual.dat') ;

t = textscan(f,'%s','Delimiter','[ ]','MultipleDelimsAsOne',true) ;

fclose(f) ;

actual = numel(t{1}) ;

v2 = NaN(actual,1) ;

for ii = 1:actual

v2(ii) = sscanf(t{1}{ii},'%f') ;

end

actual = reshape(v2,137,[])' ;


% clearvars -except expected actual

clear ans ii f s t v v2

