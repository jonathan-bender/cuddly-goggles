function sol=CrackSolution_n_GammaChange(v,n,theta,r,Gamma)
%The function calculates Sigma_{ij},D(c_f),A(c_f),S_{ij},U_{ij}
%p.171,234 Freund
%Units:  [v]=[Cr],[r]=[m],[theta]=[rad]
%Free tail: singular term: n=-1/2   higher order: 1/2,3/2.
%Stokes tail: singular term: -1/2<n<0
%Only works for \theta>0 or/theta<0 (Not Both)

%--Ilya's version
% [Cd, Cs, Cr ,nu, ~, E, mu , Gamma ,PlaneStrain]=CrackSolutionMaterialProperties;

%--My version
ParametersStruct = MaterialPropertiesPMMA;
Cs=ParametersStruct.Cs;
Cd=ParametersStruct.Cd;
Cr=ParametersStruct.Cr;
mu=ParametersStruct.mu;
nu=ParametersStruct.nu;
E=ParametersStruct.E;
% Gamma=ParametersStruct.DefaultGamma;
G=Gamma;
PlaneStrain=ParametersStruct.PlaneStrain;

% R=@(z) (Cs^-2 - 2*z.^2).^2 + 4*z.^2 .* (Cd^-2 -z.^2).^0.5.* (Cs^-2-z.^2).^0.5; %just after eq. 6.3.42
% D=@(v) -v^4*real(R(1/v)); %Due to numerical error R has an imaginary part
v=v*Cr;

alpha_d=(1-(v/Cd).^2).^0.5;
alpha_s=(1-(v/Cs).^2).^0.5;
gamma_d=(1-(v.*sin(theta)/Cd).^2).^0.5;
gamma_s=(1-(v.*sin(theta)/Cs).^2).^0.5;
D=4*alpha_d.*alpha_s-(1+alpha_s.^2).^2;

%-----Following Freund - p.234
A=alpha_s.*v.^2./D/(1-nu)/Cs^2;% I think this is only for plain strain. For plane stress should be  A=(1+nu)*alpha_s.*v.^2./D/Cs^2;

if(PlaneStrain==true)
    K=(G*E/(1-nu^2)./A).^0.5; %plane strain 
else
    K=(G*E./A).^0.5; %plane stress
end

% k=Cs/Cd;%Broberg p.330
% %----- Following Broberg p.334,336
% A=2*(1-k^2)*alpha_s.*v.^2./D/Cs^2;
% K=(G*mu*4*(1-k^2)./A).^0.5;

if (theta>0)
    theta_d=atan(alpha_d.*tan(theta));
    index=find(theta_d<0);%matlab gives -pi/2<theta<pi/2, I want 0<theta<pi
    theta_d(index)=theta_d(index)+pi;
    
    theta_s=atan(alpha_s.*tan(theta));
    index=find(theta_s<0);%matlab gives -pi/2<theta<pi/2, I want 0<theta<pi
    theta_s(index)=theta_s(index)+pi;
else
    theta_d=atan(alpha_d.*tan(theta));
    index=find(theta_d>0);%matlab gives -pi/2<theta<pi/2, I want -pi<theta<0
    theta_d(index)=theta_d(index)-pi;
    
    theta_s=atan(alpha_s.*tan(theta));
    index=find(theta_s>0);%matlab gives -pi/2<theta<pi/2, I want -pi<theta<0
    theta_s(index)=theta_s(index)-pi;
    
end

%----angular variation of stress ,Freund p.171 (I switched the "minus" sign in
%Sigma_11 , Sigma_22 and Vx. This is equivelent to take \theta->-\theta)

Sigma12_Mul_D=4*alpha_d.*alpha_s.*cos(n*theta_d).*gamma_d.^n-(1+alpha_s.^2).^2.*cos(n*theta_s).*gamma_s.^n;
Sigma12=Sigma12_Mul_D./D;

Sigma11_Mul_D=2*alpha_s.*((1+2*alpha_d.^2-alpha_s.^2).*sin(n*theta_d).*gamma_d.^n-(1+alpha_s.^2).*sin(n*theta_s).*gamma_s.^n);
Sigma11=Sigma11_Mul_D./D;

Sigma22_Mul_D=-2*alpha_s.*(1+alpha_s.^2).*(sin(n*theta_d).*gamma_d.^n-sin(n*theta_s).*gamma_s.^n);
Sigma22=Sigma22_Mul_D./D;

Vx_Mul_D=-1/mu.*v.*alpha_s.*( 2*sin(n*theta_d).*gamma_d.^n-(1+alpha_s.^2).*sin(n*theta_s).*gamma_s.^n );
Vx=Vx_Mul_D./D;

Vy_Mul_D= - 1/mu*v.*(2*alpha_d.*alpha_s.*cos(n*theta_d).*gamma_d.^n  -   (1+alpha_s.^2).*cos(n*theta_s).*gamma_s.^n);
Vy=Vy_Mul_D./D;

%----polar coordinates Timoshenko p.67
% Sigma_r=Sigma11.*(cos(theta)).^2+Sigma22.*(sin(theta)).^2+2*Sigma12.*sin(theta).*cos(theta);
% Sigma_theta=Sigma11.*(sin(theta)).^2+Sigma22.*(cos(theta)).^2-2*Sigma12.*sin(theta).*cos(theta);
% Sigma_r_theta=(Sigma22-Sigma11).*sin(theta).*cos(theta)+Sigma12.*(cos(theta).^2-sin(theta).^2);
% %------------
% Sigma_ShearMax=(1/4*(Sigma11-Sigma22).^2+Sigma12.^2).^0.5; %maximum shear Timoshenko p.22

%--------calc particle velocity (Not for general n)
sol.vx=K./(2.*pi).^0.5.*Vx.*r.^-0.5;
sol.vy=K./(2.*pi).^0.5.*Vy.*r.^-0.5;

%-------calculate stress
sol.Sxy=2*(n+1)*K/(2*pi)^0.5.*Sigma12.*r.^n;
sol.Sxx=2*(n+1)*K/(2*pi)^0.5.*Sigma11.*r.^n;
sol.Syy=2*(n+1)*K/(2*pi)^0.5.*Sigma22.*r.^n;
sol.bigSigma=Sigma22;

%-------calculate strains

%-------Works for both boundary conditions with appropriate k 
 sol.Uxy=1/(2*mu)*sol.Sxy;
%  sol.Uxx=1/(2*mu)/(2*(1-k^2))*(sol.Sxx-(1-2*k^2)*sol.Syy);
%  sol.Uyy=1/(2*mu)/(2*(1-k^2))*(sol.Syy-(1-2*k^2)*sol.Sxx);
 
if (PlaneStrain==true)
    %planes strain
    sol.Uxx=1/E*(1+nu)*(sol.Sxx*(1-nu)-nu*sol.Syy);
    sol.Uyy=1/E*(1+nu)*(sol.Syy*(1-nu)-nu*sol.Sxx);
else
    % %planes stress
    sol.Uxx=1/E*(sol.Sxx-nu*sol.Syy);
    sol.Uyy=1/E*(sol.Syy-nu*sol.Sxx);
end

%------return azimuthal functions
% sol.Sigma12=Sigma12;
% sol.Sigma11=Sigma11;
% sol.Sigma22=Sigma22;

% sol.Sigma_r=Sigma_r;
% sol.Sigma_theta=Sigma_theta;
% sol.Sigma_r_theta=Sigma_r_theta;
% sol.Sigma_ShearMax=Sigma_ShearMax;

sol.n=n;
sol.D=D;
sol.A=A;
sol.K=K;
sol.Gamma=G;
sol.v=v;
sol.Cs=Cs;
sol.Cd=Cd;
sol.Cr=Cr;
sol.theta=theta;
sol.r=r;

