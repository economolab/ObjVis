function orthCV = orthogDir(vec1,vec2)
%orthogDir Orthogonalize vec1 to vec2 
% method: orthDir1 = vec1 - proj(vec1,vec2)
% where proj(vec1,vec2) is the projection of vec1 onto vec2

% project vec1 onto vec2
proj = ((vec1'*vec2) / norm(vec2)^2) * vec2;
% substract projection from vec1
orthCV = vec1 - proj;

% test
tol = 1.e-9; % Should not check floating point numbers for exact equality, so define a tolerance
if abs(orthCV' * vec2) < tol
  return
else
    warning('not orthogonal')
end

end

