function ParametersStruct = MaterialPropertiesPMMA

PlaneStrain=true;

%--1st version
% E=5.65*1e9;
% nu=0.33;
% ro=1.177E3;     %[Kg/m^3];
% mu=E/2/(1+nu);
% Cs=(mu/ro)^0.5;
% Cd=( E*(1-nu)/ro/(1+nu)/(1-2*nu) ) ^0.5;

%--2nd version
Cd=2700;%should be plane strain velocity
Cs=1345;
ro=1.17E3;%[Kg/m^3];

nu=(2*(Cs/Cd).^2-1)/2/((Cs/Cd).^2-1);%plane strain
E=Cs^2*2*ro*(1+nu);%[Pa]
mu=Cs^2*ro;

%-------Choose true for plane strain in boundary conditions
if(PlaneStrain~=true)
    %-------Plain Stress
    Cd=(E/ro/(1-nu^2))^0.5; %approx. =2340m/s;
end

%-----------------calc Cr
R=@(z) (Cs^-2 - 2*z.^2).^2 + 4*z.^2 .* (Cd^-2 -z.^2).^0.5.* (Cs^-2-z.^2).^0.5; %just after eq. 6.3.42
D=@(v) -v.^4.*real(R(1./v)); %Due to numerical error R has an imaginary part
Cr=fzero(D,Cs);

ParametersStruct.E=E;
ParametersStruct.Cd=Cd;
ParametersStruct.Cs=Cs;
ParametersStruct.Cr=Cr;
ParametersStruct.mu=mu;
ParametersStruct.nu=nu;
ParametersStruct.PlaneStrain=PlaneStrain;
ParametersStruct.DefaultGamma=1.1;
ParametersStruct.Estat=3*1e9;


