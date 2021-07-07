function orthModes = orthogDir_v2(modes)
%orthogDir Orthogonalize all columns of modes
% method: orthDir1 = vec1 - proj(vec1,vec2)
% where proj(vec1,vec2) is the projection of vec1 onto vec2

orthModes = nan(size(modes));
orthModes(:,1) = modes(:,1);
for i = 2:size(modes,2)
    proj = ((modes(:,i)'*modes(:,i-1)) / norm(modes(:,i-1))^2) * modes(:,i-1);
    orthModes(:,i) = modes(:,i) - proj;
end

% % test
% tol = 1.e-9; % Should not check floating point numbers for exact equality, so define a tolerance
% if abs(orthCV' * vec2) < tol
%   return
% else
%     warning('not orthogonal')
% end

end
