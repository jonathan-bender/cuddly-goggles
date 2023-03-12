function [U1O,U2O,U3O]=calc_shear_sensitivity4(U1,U2,U3,gV)
%Corection for "general case"
%The input strains should not be rotated.


%U1 and U3
k=gV(1);
g=gV(2);
%U2
a2=gV(3);
k2=gV(4);
g2=0;


% %----- sg_angle=0
M=[1+g/2,-g,k+g/2;k2+g2/2,a2-k2,k2-g2/2;k+g/2,-g,1+g/2];
M_1=inv(M);

for j=1:length(U1(1,:))
    u(1,:)=U1(:,j);
    u(2,:)=U2(:,j);
    u(3,:)=U3(:,j);
    
    v=multiprod(M_1,u);
    
    U1O(:,j)=v(1,:);
    U2O(:,j)=v(2,:);
    U3O(:,j)=v(3,:);
end