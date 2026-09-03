#include "UnityCG.cginc"

struct v2f
{
    float4 clipPos : SV_POSITION;
    // Clip position, which transforms vertices coordinate to pixel coordinate on screen. (You won't need this)
    float3 worldPos : TEXTCOORD0; // World position of vertex
    float3 worldNormal : NORMAL; // World normal of vertex
};

v2f MyVertexProgram(appdata_base v)
{
    v2f o;
    // World position
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);

    // Clip position
    o.clipPos = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1.));

    // Normal in WorldSpace
    o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));


    return o;
}

half4 _LightColor0;

// Diffuse
fixed4 _DiffuseColor;

//Specular
fixed _Shininess;
fixed4 _SpecularColor;


// Emission
fixed4 _EmissionColor;


fixed4 MyFragmentProgram(v2f i) : SV_Target
{
    //TODO: Calculate the Blinn-Phong specular model here. The diffuse component is already calculated for you,
    // but the "attenuation" quantity is not determined yet. You will need to:
    // (1) Calculate the distance attenuation for point light using the formula 1/r^2 where r is the distance
    // between a point light and a surface vertex.
    // (2) Calculate the specular component. You will need to define more vectors similar to the ones in class
    // (3) Obtain the ambient component using Unity's built-in variable.
    // 
    // Hint: Check out  https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    // to learn more about built-in shader variables. You will need _WorldSpaceLightPos0,
    // _WorldSpaceCameraPos, UNITY_LIGHTMODEL_AMBIENT, and _LightColor0.
    // 
    // Hint: argument "i" is a vertex data of type "v2f" defined above. Use this data to calculate appropriate
    // directional vectors (camera view, normal, light)

    float4 color = float4(0, 0, 0, 1);
    color.rgb += _EmissionColor.rgb;

    float3 L = float3(0, 0, 0); // Light direction
    float attenuation = 1.0f;
    if (_WorldSpaceLightPos0.w != 0.0) // this is point light
    {
        float r = length(_WorldSpaceLightPos0.xyz - i.worldPos);
        attenuation = 1.0 / (1.0 + (r * r));
        L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
       
    }
    float3 N = normalize(i.worldNormal);

    // Diffuse component
    float3 diffuse = float3(0, 0, 0);
    float diffuseShade = max(dot(N, L), 0.0);
    diffuse = diffuseShade * _DiffuseColor * _LightColor0 * attenuation;

    float3 specular = float3(0, 0, 0);
    float3 ambient = float3(0, 0, 0);
    
    ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _DiffuseColor.xyz;
    
    float3 direction = normalize(_WorldSpaceCameraPos - i.worldPos);
    
    float3 H = normalize(L + direction);
  
    float HN = max(dot(H, N), 0.0);
    float HNa = pow(HN, _Shininess);
    specular = attenuation * _SpecularColor.xyz * HNa * _LightColor0.xyz;
    
    
    float IL = pow(HN, _Shininess);
    

    color.rgb += ambient + diffuse + specular;

    return color;
}
