function [Sxx,Syy,Sxy,Uxx,Uyy,Uxy,note,E]=calculate_stress_strain(U1,U2,U3,sg_angle)

%--------------------calculate strain stress
%-in the Camera axis frame (positive is oposite to pushing direction)


Uxy=(U1-U3)/2;
Uyy=U2;                     %calculated normal strain
Uxx=(U1+U3)-Uyy; %calculated transverse strain

% %------------sort the strains with ascending order of x_sg. x=0 is where the stoper is.
% Uxy=Uxy(:,sort_index)*1000; %[mStrain]
% Uyy=Uyy(:,sort_index)*1000; %[mStrain]
% Uxx=Uxx(:,sort_index)*1000; %[mStrain]

%------------------- rotate the strain (correction)
for j=1:length(Uxx(1,:))
    u(1,1,:)=Uxx(:,j);
    u(1,2,:)=Uxy(:,j);
    u(2,1,:)=Uxy(:,j);
    u(2,2,:)=Uyy(:,j);
    R=[cos(sg_angle(j)) sin(sg_angle(j)); -sin(sg_angle(j)) cos(sg_angle(j))]; % rotation => u=R(theta)u'R(-theta)
    u=multiprod(u,R);
    R=[cos(sg_angle(j)) -sin(sg_angle(j)); sin(sg_angle(j)) cos(sg_angle(j))];
    u=multiprod(R,u);
    Uxx(:,j)=u(1,1,:);
    Uxy(:,j)=u(1,2,:);
    Uyy(:,j)=u(2,2,:);
end

%---------now calc stresses using hook law and assuming Szz=0
% Cd=2700;
% Cs=1345;
% sigma=(2*(Cs/Cd).^2-1)/2/((Cs/Cd).^2-1);%plane stress

%--old version
% sigma=1/3;%poisson ratio
% E=3.2E+9/10^6 ;%youngs modulus [MPa]
% E=5.6E+9/10^6 ;%youngs modulus [MPa]

% %--new version
ParametersStruct = MaterialPropertiesPMMA;
E=ParametersStruct.E/10^6;                       % uses E dynamic [MPa]. for E static pick '''ParametersStruct.Estat'''
sigma=ParametersStruct.nu;

E=E/1000; %because U is in mStrain

% %---------Plane Stress (Szz=0)
% Sxx=-E/(1-sigma^2)*(Uxx+sigma*Uyy);  % "-" is added positive stress is compresion
% Syy=-E/(1-sigma^2)*(Uyy+sigma*Uxx); % "-" is added positive stress is compresion
% Sxy=E/(1+sigma)*Uxy;
% note='Plane Stress';

% %---------Plane Strain (Uzz=0)
% 
Sxx=-E/(1+sigma)/(1-2*sigma)*((1-sigma)*Uxx+sigma*Uyy); % "-" is added positive stress is compresion
Syy=-E/(1+sigma)/(1-2*sigma)*((1-sigma)*Uyy+sigma*Uxx); % "-" is added positive stress is compresion
Sxy=E/(1+sigma)*Uxy;
note='Plane Strain';
%----
% Uzz=-sigma/(1-sigma)*(Uxx+Uyy);
% Sxx=E/((1+sigma)*(1-2*sigma))*((1-sigma)*Uxx+sigma*(Uyy+Uzz));
% Syy=E/((1+sigma)*(1-2*sigma))*((1-sigma)*Uyy+sigma*(Uxx+Uzz));
% Sxy=E/(1+sigma)*Uxy;
