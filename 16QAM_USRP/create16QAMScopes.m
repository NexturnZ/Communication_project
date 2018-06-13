function hScopes = create16QAMScopes

persistent hScope
if isempty(hScope)
    hScope = SixteenQAMScopes;
end
hScopes = hScope;

end
