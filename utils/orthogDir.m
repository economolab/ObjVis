function orthCV = orthogDir(dirToOrthog,refDir)
%orthogDir Orthogonalize dirToOrthog to refDir using gram-schmidt
Q = gschmidt([refDir , dirToOrthog]);
orthCV = Q(:,2);
end

