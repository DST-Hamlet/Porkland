   ui_anim_cc_nolight      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                             
   TIMEPARAMS                                FLOAT_PARAMS                            SAMPLER    +         COLOUR_XFORM                                                                                AMBIENTLIGHT                                ui_anim_cc_nolight.vs�  #define UI_CC
uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;
uniform vec4 TIMEPARAMS;
uniform vec3 FLOAT_PARAMS;

attribute vec4 POS2D_UV;                  // x, y, u + samplerIndex * 2, v

varying vec3 PS_TEXCOORD;
varying vec3 PS_POS;

#if defined( FADE_OUT )
    uniform mat4 STATIC_WORLD_MATRIX;
    varying vec2 FADE_UV;
#endif

#if defined( UI_HOLO )
	varying vec3 PS_TEXCOORD1;
#endif

#if defined( HOLO )
	float filmSkipRand() // This should match the function with the same name in anim.ps
	{
		float steps = 12.;
		float c = fract(sin(ceil(TIMEPARAMS.x * steps) / steps) * 10000.);
		return (c * -.36) * step(.78, c);
	}
#endif

void main()
{
    vec3 POSITION = vec3(POS2D_UV.xy, 0);
	// Take the samplerIndex out of the U.
    float samplerIndex = floor(POS2D_UV.z/2.0);
    vec3 TEXCOORD0 = vec3(POS2D_UV.z - 2.0*samplerIndex, POS2D_UV.w, samplerIndex);

	vec3 object_pos = POSITION.xyz;
	vec4 world_pos = MatrixW * vec4( object_pos, 1.0 );

	if(FLOAT_PARAMS.z > 0.0)
	{
		float world_x = MatrixW[3][0];
		float world_z = MatrixW[3][2];
		world_pos.y += sin(world_x + world_z + TIMEPARAMS.x * 3.0) * 0.025;
	}

	mat4 mtxPV = MatrixP * MatrixV;
	gl_Position = mtxPV * world_pos;

	#if defined( HOLO )
		float filmSkipOffset = sin(filmSkipRand()) * .4;
		gl_Position.y += filmSkipOffset;
	#endif

	PS_TEXCOORD = TEXCOORD0;
	PS_POS = world_pos.xyz;

#if defined( FADE_OUT )
	vec4 static_world_pos = STATIC_WORLD_MATRIX * vec4( POSITION.xyz, 1.0 );
    vec3 forward = normalize( vec3( MatrixV[2][0], 0.0, MatrixV[2][2] ) );
    float d = dot( static_world_pos.xyz, forward );
    vec3 pos = static_world_pos.xyz + ( forward * -d );
    vec3 left = cross( forward, vec3( 0.0, 1.0, 0.0 ) );

    FADE_UV = vec2( dot( pos, left ) / 4.0, static_world_pos.y / 8.0 );
#endif

#if defined( UI_HOLO )
	PS_TEXCOORD1 = gl_Position.xyw;
#endif
}    ui_anim_cc_nolight.ps�  #define UI_CC
#if defined( GL_ES )
precision mediump float;
#endif

#if defined( TRIPLE_ATLAS )
	#define SAMPLER_COUNT 6
#elif defined( UI_CC )
	#define SAMPLER_COUNT 5
#elif defined( UI_HOLO )
	#define SAMPLER_COUNT 3
#else
	#define SAMPLER_COUNT 2
#endif

uniform sampler2D SAMPLER[SAMPLER_COUNT];

varying vec3 PS_TEXCOORD;

uniform mat4 COLOUR_XFORM;

#if defined( UI_HOLO )
    varying vec3 PS_TEXCOORD1;
    
    uniform vec3 EROSION_PARAMS;
    
    #define UI_HOLO_SAMPLER         SAMPLER[2]
    #define HOLO_ERODE_INTENSITY    EROSION_PARAMS.x
    #define HOLO_TIME               EROSION_PARAMS.y
    #define NEGATIVE_HOLO_LERP      EROSION_PARAMS.z
#endif

#if defined( UI_CC )
#ifndef LIGHTING_H
#define LIGHTING_H

#if !defined( UI_CC )
// Lighting
varying vec3 PS_POS;
#endif

// xy = min, zw = max
uniform vec4 LIGHTMAP_WORLD_EXTENTS;

#define LIGHTMAP_TEXTURE SAMPLER[3]

#ifndef LIGHTMAP_TEXTURE
	#error If you use lighting, you must #define the sampler that the lightmap belongs to
#endif

#if defined( UI_CC )
vec3 CalculateLightingContribution(vec2 pos)
{
	vec2 uv = ( pos - LIGHTMAP_WORLD_EXTENTS.xy ) * LIGHTMAP_WORLD_EXTENTS.zw;
	return texture2D( LIGHTMAP_TEXTURE, uv.xy ).rgb;
}
#else
vec3 CalculateLightingContribution()
{
	vec2 uv = ( PS_POS.xz - LIGHTMAP_WORLD_EXTENTS.xy ) * LIGHTMAP_WORLD_EXTENTS.zw;
	return texture2D( LIGHTMAP_TEXTURE, uv.xy ).rgb;
}

vec3 CalculateLightingContribution( vec3 normal )
{
	return vec3( 1, 1, 1 );
}
#endif

#endif //LIGHTING.h


	uniform vec4 AMBIENTLIGHT;
	uniform vec4 SCREEN_PARAMS;
	uniform vec3 LIGHTMAPPOS;
	uniform vec3 CAMERARIGHT;
	uniform vec4 UI_LIGHTPARAMS;

	#define SCREENMAPPING_X UI_LIGHTPARAMS.x
	#define SCREENMAPPING_Y UI_LIGHTPARAMS.y
	#define START_LIGHT_HIGHT UI_LIGHTPARAMS.z
	#define MAX_LIGHT_HEIGHT_FALLOFF UI_LIGHTPARAMS.w

	float quadIn_circularOut(float t) {
		return mix(
			+16.0 * pow(t, 5.0),
			0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0),
			step(0.5, t));
	}

	#define COLOUR_CUBE SAMPLER[4]
#ifndef COLOURCUBE_H
#define COLOURCUBE_H

#ifndef COLOUR_CUBE
	#error If you use colourcube, you must #define the sampler that the colourcube belongs to
#endif

const float CUBE_DIMENSION = 32.0;
const float CUBE_WIDTH = ( CUBE_DIMENSION * CUBE_DIMENSION );
const float CUBE_HEIGHT =( CUBE_DIMENSION );
const float ONE_OVER_CUBE_WIDTH =  1.0 / CUBE_WIDTH;
const float ONE_OVER_CUBE_HEIGHT =  1.0 / CUBE_HEIGHT;

//make sure to premultiply the alpha if its value isn't 1!
vec3 ApplyColourCube(vec3 colour)
{
	vec3 intermediate = colour.rgb * vec3( CUBE_DIMENSION - 1.0, CUBE_DIMENSION - 1.0, CUBE_DIMENSION - 1.0 );

	vec2 floor_uv = vec2( ( min( intermediate.r + 0.5, 31.0 ) + floor( intermediate.b ) * CUBE_DIMENSION ) * ONE_OVER_CUBE_WIDTH,1.0 - ( min( intermediate.g + 0.5, 31.0 ) * ONE_OVER_CUBE_HEIGHT ) );
	vec2 ceil_uv = vec2( ( min( intermediate.r + 0.5, 31.0 ) + ceil( intermediate.b ) * CUBE_DIMENSION ) * ONE_OVER_CUBE_WIDTH,1.0 - ( min( intermediate.g + 0.5, 31.0 ) * ONE_OVER_CUBE_HEIGHT ) );
	vec3 floor_col = texture2D( COLOUR_CUBE, floor_uv.xy ).rgb;
	vec3 ceil_col = texture2D( COLOUR_CUBE, ceil_uv.xy ).rgb;
	return mix(floor_col, ceil_col, intermediate.b - floor(intermediate.b) );	
}

#endif //COLOURCUBE.h

#endif

void main()
{
    vec4 colour;
    
#if defined( TRIPLE_ATLAS )
    if( PS_TEXCOORD.z < 0.5 )
    {
        colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
    }
    else if( PS_TEXCOORD.z < 1.5 )
    {
        colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
    }
    else
    {
        colour.rgba = texture2D( SAMPLER[5], PS_TEXCOORD.xy );
    }
#else
    if( PS_TEXCOORD.z < 1.5 )
    {
        if( PS_TEXCOORD.z < 0.5 )
		{
			colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
		}
		else
		{
            colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
        }
    }
#endif

#if defined( UI_HOLO )
    vec4 orig = colour;

    vec2 effectUV = PS_TEXCOORD1.xy;

    vec2 lineUV = vec2(effectUV.x * 1., HOLO_TIME * .16);
    float rgbLines = smoothstep(1., .75, texture2D( UI_HOLO_SAMPLER, lineUV ).g);
    float alphaLines = step(HOLO_ERODE_INTENSITY - .01, texture2D( UI_HOLO_SAMPLER, lineUV ).g);

    float filmGrainTime = ceil(HOLO_TIME * 10.) * .1; // Grain runs on 1/10 framerate

    float grain = texture2D( UI_HOLO_SAMPLER, effectUV.xy * 1. + mod(filmGrainTime * 192.7249753, 9e4)).b;
    float mask = grain * rgbLines;
    colour.rgb *= .35 + mask * .65;

    // Color grading
    colour.rgb = mix(colour.rgb, vec3(.85, .68, .57), .05);

    // Fluctuating exposure
    float exposureAdd = texture2D( UI_HOLO_SAMPLER, vec2(mod(HOLO_TIME, 1.), mod(floor(HOLO_TIME) / 256., 256.))).r;
    colour.rgb += vec3(exposureAdd * .22);

    float baseAlpha = colour.a;
    float alpha = baseAlpha * alphaLines;
    colour = mix(orig, vec4(colour.r * alpha, colour.g * alpha, colour.b * alpha, alpha), abs(NEGATIVE_HOLO_LERP));
#endif

	colour = colour.rgba * COLOUR_XFORM;
	colour.rgb = min(colour.rgb, colour.a);

#if defined( UI_CC )
	colour.rgb *= AMBIENTLIGHT.rgb;

    gl_FragColor = vec4(ApplyColourCube(colour.rgb) * colour.a, colour.a);
#else
	gl_FragColor = colour.rgba;
#endif

}                                