function Velocity=getTipVelocity(displacement,timeline,smth)

displacement=smooth(displacement,smth);

Velocity=zeros(size(displacement));
for i=2:size(displacement)
    Velocity(i)=(displacement(i)-displacement(i-1))/(timeline(i)-timeline(i-1));
end


end