

////////////////////////////////////////////////////////////////////////////////
// Macro Builders///////////// /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define SHAPE_TRANS(NAME,F) shape NAME (sdf_sampler2 origin) {F}
#define CONVEX_HULL_TRANS(NAME,F) hull NAME (sdf_sampler2 origin, ray2 ray) {F} 
#define SHAPE(NAME,...) NAME(origin,...)
#define CONVEX_HULL(NAME,...) NAME(origin,ray,...)


#define PRIM(NAME,TARGET,...)                                                  \
SHAPE_TRANS(TARGET,                                                            \
  sdf _sdf = SHAPE(NAME,...);                                                  \
  return new(_sdf);)                                                           \
CONVEX_HULL_TRANS(TARGET,                                                      \
  ray.direction = ray.direction - origin.position;                                                  \
  hull result = NAME(ray,...);                                          \
  result.distance -= dot(ray.direction,origin.position);                                      \
  return result;)


#define SIMPLE_MODIFIER1(NAME,TARGET,A,...)                                    \
SHAPE_TRANS(TARGET, return NAME(SHAPE(A),...);)                                \
CONVEX_HULL_TRANS(TARGET, return NAME(CONVEX_HULL(A),...);)     

#define SIMPLE_MODIFIER2(NAME,TARGET,A,B,...)                                  \
SHAPE_TRANS(TARGET, return NAME(SHAPE(A),SHAPE(B),...);)                       \
CONVEX_HULL_TRANS(TARGET, return NAME(CONVEX_HULL(A),CONVEX_HULL(B),...);)     

#define SIMPLE_SHAPE_MODIFIER1(NAME,TARGET,A,...)                              \
SHAPE_TRANS(TARGET, return NAME(SHAPE(A),...);)                                \
CONVEX_HULL_TRANS(TARGET, return CONVEX_HULL(A);)

#define SIMPLE_SHAPE_MODIFIER2(NAME,TARGET,A,B,...)                            \
SHAPE_TRANS(TARGET, return NAME(SHAPE(A),SHAPE(B),...);)                       \
CONVEX_HULL_TRANS(TARGET, return CONVEX_HULL(A);)



// float mix (float a, float b, float w1, float w2) {
//     return (a * w1 + b * w2) / (w1 + w2);
// }

// vec2 mix (vec2 a, float w1, vec2 b, float w2) {
//     vec2 c;
//     float ws = w1 + w2;
//     c.x = (a.x * w1 + b.x * w2) / ws;
//     c.y = (a.y * w1 + b.y * w2) / ws;
//     return c;
// }

// vec3 mix (vec3 a, float w1, vec3 b, float w2) {
//     vec3 c;
//     float ws = w1 + w2;
//     c.x = (a.x * w1 + b.x * w2) / ws;
//     c.y = (a.y * w1 + b.y * w2) / ws;
//     c.z = (a.z * w1 + b.z * w2) / ws;
//     return c;
// }

// vec4 mix (vec4 a, float w1, vec4 b, float w2) {
//     vec4 c;
//     float ws = w1 + w2;
//     c.x = (a.x * w1 + b.x * w2) / ws;
//     c.y = (a.y * w1 + b.y * w2) / ws;
//     c.z = (a.z * w1 + b.z * w2) / ws;
//     c.w = (a.w * w1 + b.w * w2) / ws;
//     return c;
// }




float bismooth (float a, float exp) {
  float a2 = a * 2.0 - 1.0;
  float a3 = pow(abs(a2),exp);
  float a4 = (a3 * sign(a2) + 1.0) * 0.5;
  return a4;
}

float clamp (float a) { return clamp(a, 0.0, 1.0); }
vec2  clamp (vec2  a) { return clamp(a, 0.0, 1.0); }
vec3  clamp (vec3  a) { return clamp(a, 0.0, 1.0); }
vec4  clamp (vec4  a) { return clamp(a, 0.0, 1.0); }



float smoothstep (float a) {
    return smoothstep (0.0, 1.0, a);
}

// TODO: check if still useful
vec3 smoothMerge (float d1, float d2, vec3 c1, vec3 c2, float width) {
    return mix (c1,c2,bismooth(clamp((d1-d2+2.0*width)/(4.0*width)),2.0));
}




/////////////////////////
////// Conversions //////
/////////////////////////

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}



/////////////////////////////////////////////////////////////////




///////////////////////
////// Constants //////
///////////////////////

#define PI 3.14159265
#define TAU (2.0*PI)
#define PHI (sqrt(5.0)*0.5 + 0.5)
const float INF = 1e10;



/////////////////////
////// Helpers //////
/////////////////////

float square (float x) {return x*x;}
vec2  square (vec2  x) {return x*x;}
vec3  square (vec3  x) {return x*x;}

float lengthSqr (vec3 x) {return dot(x, x);}

float maxEl (vec2 v) {return max(v.x, v.y);}
float maxEl (vec3 v) {return max(max(v.x, v.y), v.z);}
float maxEl (vec4 v) {return max(max(v.x, v.y), max(v.z, v.w));}

float minEl (vec2 v) {return min(v.x, v.y);}
float minEl (vec3 v) {return min(min(v.x, v.y), v.z);}
float minEl (vec4 v) {return min(min(v.x, v.y), min(v.z, v.w));}

float signPlus (float x) { return (x<0.0)?-1.0:1.0; }
vec2  signPlus (vec2  v) { return vec2((v.x<0.0)?-1.0:1.0, (v.y<0.0)?-1.0:1.0);}
vec3  signPlus (vec3  v) { return vec3((v.x<0.0)?-1.0:1.0, (v.y<0.0)?-1.0:1.0, (v.z<0.0)?-1.0:1.0);}
vec4  signPlus (vec4  v) { return vec4((v.x<0.0)?-1.0:1.0, (v.y<0.0)?-1.0:1.0, (v.z<0.0)?-1:1, (v.w<0.0)?-1.0:1.0);}



///////////////////////
////// Transform //////
///////////////////////

vec2 sdf_translate (vec2 p, vec2 t) { return p - t; }

vec2 sdf_rotate (vec2 p, float angle) {
	return p*cos(angle) + vec2(p.y,-p.x)*sin(angle);
}

vec2 cartesian2polar (vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}












/////////////////////
////// Filters //////
/////////////////////

float sdf_blur (float d, float radius, float power) {
    return 1.0-2.0*pow(clamp((radius - d) / radius),power);
}




////////////////////////////////////////////////////////////////////////////////
// Signed Distance Field ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct sdf {
  float distance;
};

struct sdf_sampler2 {
  vec2 position;
};

float length (sdf_sampler2 sampler) {
  return length(sampler.position);
}



////////////////////////////////////////////////////////////////////////////////
// Vector Distance Field 2D ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct vdf2 {
  vec2 distance;
};

struct vdf_sampler2 {
  vec2 position;
};

float length (vdf_sampler2 sampler) {
  return length(sampler.position);
}



////////////////////////////////////////////////////////////////////////////////
// Vector Distance Field 3D ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct vdf3 {
  vec3 distance;
};

struct vdf_sampler3 {
  vec3 position;
};

float length (vdf_sampler3 sampler) {
  return length(sampler.position);
}









////////////////////////////////////////////////////////////////////////////////
// Convex Hulls ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct hull {
  float distance;
};

struct ray2 {
  vec2  direction;
  float offset;
};

struct ray3 {
  vec3  direction;
  float offset;
};








//////////////////////
////// Booleans //////
//////////////////////



////// Inverse //////



sdf inverse (sdf s) {
    s.distance *= -1.0;
    return s;
}


////// Union //////

sdf union (sdf a, sdf b) {
    return sdf(min(a.distance, b.distance));
}

sdf unionRound (sdf a, sdf b, float r) {
    vec2 v = max(vec2(r-a.distance, r-b.distance), 0.0);
	return sdf(max(r, union(a,b).distance) - length(v));
}

sdf unionChamfer (sdf a, sdf b, float r) {
    sdf normalDist  = union(a,b);
    sdf chamferDist = sdf((a.distance + b.distance - r) * sqrt(0.5));
	return union(normalDist, chamferDist);
}

sdf union (sdf a, sdf b, float r) {
    return unionRound(a,b,r);
}



////// Intersection //////

sdf intersection (sdf a, sdf b) {
    return sdf(max(a.distance, b.distance));
}

sdf intersectionRound (sdf a, sdf b, float r) {
    sdf c    = intersection(a,b);
	vec2  v    = max(vec2(r+a.distance, r+b.distance), 0.0);
	float dist = min(-r, c.distance) + length(v);
    c.distance = dist;
    return c;
}

sdf intersectionChamfer (sdf a, sdf b, float r) {
    sdf c    = intersection(a,b);
	float dist = max(c.distance, (a.distance+r+b.distance)*sqrt(0.5));
    c.distance = dist;
    return c;
}

sdf intersection (sdf a, sdf b, float r) {
    return intersectionRound(a,b,r);
}



////// Difference //////

sdf difference (sdf a, sdf b) {
    return intersection(a, inverse(b));
}

sdf difference (sdf a, sdf b, float r) {
    return intersection(a, inverse(b), r);
}

sdf differenceRound (sdf a, sdf b, float r) {
	return intersectionRound (a, inverse(b), r);
}

sdf differenceChamfer (sdf a, sdf b, float r) {
	return intersectionChamfer(a, inverse(b), r);
}







////////////////////////////////
////// Shape modification //////
////////////////////////////////

float sdf_grow   (float size, float d)  { return d - size;  }
float sdf_shrink (float size, float d)  { return d + size;  }
float sdf_border (float d)              { return abs(d);    }
float sdf_flatten(float a)              { return clamp(-a); }
// float sdf_render (float d)              { return clamp((0.5 - d) / zoom); }
// float sdf_render (float d, float w)     { return clamp((0.5 - d) / zoom / w); }

float sdf_removeOutside (float d) { return (d > 0.0) ?  INF : d; }
float sdf_removeInside  (float d) { return (d < 0.0) ? -INF : d; }

float sdf_render(float d, float w) {
  float anti = fwidth(d) + w/2.0;
  return (1.0 - smoothstep(-anti, anti, d));
}

float sdf_render(float d) {
  return sdf_render(d, 0.0);
}


float sdf_render(sdf s, float w) {
  float anti = fwidth(s.distance) + w/2.0;
  return (1.0 - smoothstep(-anti, anti, s.distance));
}

float sdf_render(sdf s) {
  return sdf_render(s, 0.0);
}

sdf grow (sdf s, float size) {
    return sdf(s.distance - size);
}





////////////////////////////////////////////////////////////////////////////////
// 2D Primitive shapes /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////// Plane //////

hull plane (ray2 ray) {
    return hull(0.0);
}

sdf plane (sdf_sampler2 p) {
    return sdf(-1.0);
}

// vdf2 plane (sdf_sampler2 p)


////// Pie //////

sdf pie (vec2 p, float angle) {
    float distance = abs(p).x*cos(angle/2.0) - p.y*sin(angle/2.0);
    return sdf(distance);
}

sdf pie (vec2 p) {
    return pie(p, 0.0);
}


////// Half Plane //////

sdf half_plane_right  (vec2 p) {return sdf(-p.x);}
sdf half_plane_left   (vec2 p) {return sdf( p.x);}
sdf half_plane_top    (vec2 p) {return sdf(-p.y);}
sdf half_plane_bottom (vec2 p) {return sdf( p.y);}
sdf half_plane        (vec2 p) {return half_plane_top(p);}

sdf half_plane(vec2 p, vec2 direction) {
  float dx = -direction.x;
  float dy = -direction.y;
  float dist = (dx * p.x + dy * p.y) / sqrt(dx*dx + dy*dy);
  return sdf(dist);
}

sdf half_plane (vec2 p, float angle) {
  return half_plane(p, sdf_rotate(vec2(0.0,1.0), angle));
}


////// Half Plane Fast //////

sdf half_plane_fast(vec2 p, vec2 direction) {
  float dist = direction.x * p.x + direction.y * p.y;
  return sdf(dist);
}

sdf half_plane_fast(vec2 p, float angle) {
  return half_plane_fast(p, sdf_rotate(vec2(0.0,1.0), angle));
}

sdf half_plane_fast(vec2 p) {
    return half_plane_fast(p, vec2(0.0, 1.0));
}



////// Rectangle //////


hull rectangle(ray2 ray, vec2 size) {
    vec2  pt   = size / 2.0;
    vec2  adir = abs(ray.direction);
    float dist = dot(adir,pt);
    if (ray.offset < 0.0) {
        ray.offset *= mix(sqrt(2.0), 1.0, cos(atan(adir.x/adir.y))); // FIXME
    }
    return hull(dist + ray.offset); 
}

sdf rectangle_sharp(vec2 p, vec2 size) {
    vec2  size2 = size / 2.0;
    float dist  = maxEl(abs(p) - size2);
    return sdf(dist);
}

sdf rectangle (sdf_sampler2 sampler, vec2 size) {
  size       = size / 2.0;
  vec2  d    = abs(sampler.position) - size;
  float dist = maxEl(min(d, 0.0)) + length(max(d, 0.0));
  return sdf(dist);
}

// sdf rectangle (vec2 p, vec2 size, vec4 corners) {
//   float tl = corners[0];
//   float tr = corners[1];
//   float br = corners[2];
//   float bl = corners[3];

//   size /= 2.0;
//   float dist;

//        if (p.x <  - size.x + tl && p.y >   size.y - tl ) { dist = length (p - vec2(- size.x + tl,   size.y - tl)) - tl; }
//   else if (p.x >    size.x - tr && p.y >   size.y - tr ) { dist = length (p - vec2(  size.x - tr,   size.y - tr)) - tr; }
//   else if (p.x <  - size.x + bl && p.y < - size.y + bl ) { dist = length (p - vec2(- size.x + bl, - size.y + bl)) - bl; }
//   else if (p.x >    size.x - br && p.y < - size.y + br ) { dist = length (p - vec2(  size.x - br, - size.y + br)) - br; }
//   else {
//     vec2 d = abs(p) - size;
//     dist = min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
//   }
//   return sdf(dist);
// }

// sdf rectangle (vec2 p, vec2 size, vec3 r) {
//   return rectangle(p, size, vec4(r.x,r.y,r.z,r.y));
// }

// sdf rectangle (vec2 p, vec2 size, vec2 r) {
//   return rectangle(p, size, vec4(r.x,r.y,r.x,r.y));
// }

// sdf rectangle (vec2 p, vec2 size, float r1, float r2, float r3, float r4) {
//   return rectangle(p, size, vec4(r1,r2,r3,r4));
// }

// sdf rectangle (vec2 p, vec2 size, float r1, float r2, float r3) {
//   return rectangle(p, size, vec3(r1,r2,r3));
// }

// sdf rectangle (vec2 p, vec2 size, float r1, float r2) {
//   return rectangle(p, size, vec2(r1,r2));
// }

// sdf rectangle (vec2 p, vec2 size, float r) {
//   return grow(rectangle(p, size-2.0*r), r);
// }

// sdf rectangle (vec2 p) {
//   return rectangle(p, vec2(10.0,10.0));
// }

// sdf rectangle (vec2 p, float w, float h, float r1, float r2, float r3, float r4) {
//     return rectangle(p, vec2(w,h), r1, r2, r3, r4);
// }

// sdf rectangle (vec2 p, float w, float h, float r1, float r2, float r3) {
//     return rectangle(p, vec2(w,h), r1, r2, r3);
// }

// sdf rectangle (vec2 p, float w, float h, float r1, float r2) {
//     return rectangle(p, vec2(w,h), r1, r2);
// }

// sdf rectangle (vec2 p, float w, float h, float r1) {
//     return rectangle(p, vec2(w,h), r1);
// }

hull rectangle (ray2 ray, float w, float h) {
    return rectangle(ray, vec2(w,h));
}
sdf rectangle (sdf_sampler2 sampler, float w, float h) {
    return rectangle(sampler, vec2(w,h));
}

// hull rectangle (ray2 ray, float w) {
//     return rectangle(ray, vec2(w,w));
// }
// sdf rectangle (vec2 p, float w) {
//     return rectangle(p, vec2(w,w));
// }




////// Triangle //////

sdf triangle (vec2 p, float width, float height) {
  vec2  n    = normalize(vec2(height, width / 2.0));
  float y    = p.y + height / 2.0;
  float dist = max(abs(p).x*n.x + y*n.y - (height*n.y), -y);
  return sdf(dist);
}

sdf triangle (vec2 p, float side) {
    float height = side * sqrt(3.0) / 2.0;
    return triangle(p, side, height);
}

sdf triangle (vec2 p) {
    return triangle(p, 10.0);
}


////// Circle ///////
#define CIRCLE(...) PRIM(circle,...) 

hull circle(ray2 ray, float radius) {
    return hull(radius + ray.offset); 
}

// vdf2 circle (vdf_sampler2 sampler, float radius) {
//     return vdf2(length(sampler) - radius);
// }

sdf circle (sdf_sampler2 sampler, float radius) {
    return sdf(length(sampler) - radius);
}

// sdf circle (sdf_sampler2 sampler, float radius, float angle) {
//   return intersection(circle(sampler,radius), pie(sampler,angle));
// }

// sdf circle (sdf_sampler2 sampler) {
//     return circle(sampler, 10.0);
// }




// ////// Ellipse //////

// sdf ellipse (vec2 p, float r1, float r2)
// {
//     vec2  r    = vec2(r1,r2);
//     float k0   = length(p/r);
//     float k1   = length(p/(r*r));
//     float dist = k0*(k0-1.0)/k1;
//     return sdf(dist);
// }

// sdf ellipse (vec2 p, float r) {
//     return circle(p, r);
// }


// ////// Ring //////

// sdf ring(vec2 p, float radius, float width) {
//   width  /= 2.0;
//   radius -= width;
//   sdf s = circle(p,radius);
//   s.distance = abs(s.distance) - width;
//   return s;
// }

// sdf ring(vec2 p, float radius, float width, float angle) {
//    return intersection(ring(p,radius,width), pie(p,angle));
// }

// sdf ring(vec2 p, float radius) {
//    return ring(p, radius, 0.0);
// }

// sdf ring(vec2 p) {
//    return ring(p, 10.0);
// }



////// Line //////

sdf line(vec2 p, vec2 direction, float width) {
  float len  = length(direction);
  vec2  n    = direction / len;
  vec2  proj = max(0.0, min(len, dot(p,n))) * n;
  float dist = length(p-proj) - (width/2.0);
  return sdf(dist);
}



////// Bezier curve //////

// Test if `p` crosses line (`a`, `b`), returns sign of result
float testPointOnLine(vec2 p, vec2 a, vec2 b) {
    return sign((b.y-a.y) * (p.x-a.x) - (b.x-a.x) * (p.y-a.y));
}

// Determine which side we're on (using barycentric parameterization)
float bezier_sign(vec2 p, vec2 A, vec2 B, vec2 C)
{
    vec2 a = C - A, b = B - A, c = p - A;
    vec2 bary = vec2(c.x*b.y-b.x*c.y,a.x*c.y-c.x*a.y) / (a.x*b.y-b.x*a.y);
    vec2 d = vec2(bary.y * 0.5, 0.0) + 1.0 - bary.x - bary.y;
    return mix(sign(d.x * d.x - d.y), mix(-1.0, 1.0,
        step(testPointOnLine(p, A, B) * testPointOnLine(p, B, C), 0.0)),
        step((d.x - d.y), 0.0)) * testPointOnLine(B, A, C);
}

// Solve cubic equation for roots
vec3 bezier_solveCubic(float a, float b, float c)
{
    float p = b - a*a / 3.0, p3 = p*p*p;
    float q = a * (2.0*a*a - 9.0*b) / 27.0 + c;
    float d = q*q + 4.0*p3 / 27.0;
    float offset = -a / 3.0;
    if(d >= 0.0) {
        float z = sqrt(d);
        vec2 x = (vec2(z, -z) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        return vec3(offset + uv.x + uv.y);
    }
    float v = acos(-sqrt(-27.0 / p3) * q / 2.0) / 3.0;
    float m = cos(v), n = sin(v)*1.732050808;
    return vec3(m + m, -n - m, n - m) * sqrt(-p / 3.0) + offset;
}

float sdf_quadraticCurve(vec2 p, vec2 A, vec2 B)
{
    vec2 a = mix(A + vec2(1e-4), A, abs(sign(A * 2.0 - B)));
    vec2 b = -A * 2.0 + B;
    vec2 c = a * 2.0;
    vec2 d = -p;
    vec3 k = vec3(3.*dot(a,b),2.*dot(a,a)+dot(d,b),dot(d,a)) / dot(b,b);
    vec3 t = clamp(bezier_solveCubic(k.x, k.y, k.z));
    vec2 pos = (c + b*t.x)*t.x;
    float dis = length(pos - p);
    pos = (c + b*t.y)*t.y;
    dis = min(dis, length(pos - p));
    return dis;
}

#define quadraticCurve_interiorCheck_helper(f) if (f>0. && f<1. && mix(a.x*f,mix(a.x,b.x,f),f)<p.x) inside=!inside;
bool quadraticCurve_interiorCheck(vec2 p, vec2 a, vec2 b) {
  const float eps = 1e-7;
  bool  inside = false;
  float root, A, B, C;

  // http://alienryderflex.com/polyspline/
  // "What happens if F is exactly 0, or exactly 1?
  // This opens up a whole can of headaches that we’d rather not deal with, for the sake of simpler code and better execution speed.
  // Probably the easiest way to avoid the problem is just to add a very small value (say, 0.000001) to the test point’s y-coordinate
  // before testing the point.  That will pretty much guarantee that F will never be exactly 0 or 1."

  // FIXME
  // It is still not working sometimes when mooving slowly on scren.
  // We cannot discover here it if failed and re-run it again, because we're running for every p
  // and we dont know if it failed for other p. If we then move, we do other artifacts!
  float ydelta = 0.000007;

  A = b.y - a.y - a.y + ydelta;
  B = 2.*a.y + ydelta;
  C = -p.y + ydelta;
  if (abs(A)<eps) {
    quadraticCurve_interiorCheck_helper(-C / B);
  } else {
	root = B*B - 4.*A*C;
	if (root>0.) {
	  root = sqrt(root);
      quadraticCurve_interiorCheck_helper((-B - root) / (2.*A));
	  quadraticCurve_interiorCheck_helper((-B + root) / (2.*A));
	}
  }
  return inside;
}


#define coverSegment_line_check(f) if (f>0. && f<1. && mix(a.x,mix(a.x,b.x,f),f)<p.x) inside=!inside;
bool coverSegment_line(vec2 p, vec2 a, vec2 b) {
  const float eps = 1e-7;
  bool  inside = false;
  float root, A, B;

  A = b.y - a.y;
  B = a.y - p.y;
  root = - 4.*A*B;
  if (root>0.) {
    root = sqrt(root);
    coverSegment_line_check((-root) / (2.*A));
    coverSegment_line_check((root)  / (2.*A));
  }
  return inside;
}

bool interiorChec_union(bool c1, bool c2) {
  if(c2) {return !c1;} else {return c1;}
}

// vec2[9] bezier_convert4To3(vec2 p0, vec2 p1, vec2 p2, vec2 p3) {
//   vec2 p01    = (p0  + p1) /2.;
//   vec2 p12    = (p1  + p2) /2.;
//   vec2 p23    = (p2  + p3) /2.;
//   vec2 p0_01  = (p0  + p01)/2.;
//   vec2 p23_3  = (p23 + p3) /2.;
//   vec2 p01_12 = (p01 + p12)/2.;
//   vec2 p23_12 = (p23 + p12)/2.;
//
//   vec2 np0 = p0;
//   vec2 np8 = p3;
//   vec2 np1 = (p01 + p0_01)/2.;
//   vec2 np7 = (p23 + p23_3)/2.;
//   vec2 np4 = (p01_12 + p23_12)/2.;
//   vec2 np3 = ((p01_12 + np4)/2. + p01_12)/2.;
//   vec2 np5 = ((p23_12 + np4)/2. + p23_12)/2.;
//   vec2 np2 = (np1 + np3)/2.;
//   vec2 np6 = (np5 + np7)/2.;
//
//   return vec2[9](np0,np1,np2,np3,np4,np5,np6,np7,np8);
// }

// USAGE
// float d1       = sdf_quadraticCurve           (p1, A,B);
// bool  d1_cover = quadraticCurve_interiorCheck (p1, A,B);
// float d2       = sdf_quadraticCurve           (p2, C,D);
// bool  d2_cover = quadraticCurve_interiorCheck (p2, C,D);
// float d3       = sdf_quadraticCurve           (p3, E,F);convex
// bool  d3_cover = quadraticCurve_interiorCheck (p3, E,F);
// bool isInside = interiorChec_union(interiorChec_union(cover1,cover2),cover3);



vec2 sdf_repeat (vec2 p, vec2 direction) {
    return mod(p,direction);
}



///////////////////////
////// Debugging //////
///////////////////////


vec3 sdf_debug (float a, float gridScale) {
    float gridLines = smoothstep(0.0, 0.2, 2.0 * abs(mod(a/gridScale, 1.0) - 0.5));
    float zeroLines = smoothstep(0.0, 0.2, 1.0 - abs(a));
    float hue       = mod(a/1000.0 + 0.0, 1.0);
    vec3  bgCol     = hsv2rgb(vec3(hue,0.8,0.8));
    return bgCol * gridLines + vec3(zeroLines);
}

vec3 sdf_debug (float a) {
    return sdf_debug (a, 10.0);
}







vec3 Uncharted2ToneMapping(vec3 color) {
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	float exposure = 2.;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	return color;
}

//
// interesting part starts here
//
// the meter uses the "fusion" gradient, which goes from dark magenta (0) to white (1)
// (often seen in heatmaps in papers etc)
//

vec3 fusion(float x) {
	float t = clamp(x,0.0,1.0);
	return clamp(vec3(sqrt(t), t*t*t, max(sin(PI*1.75*t), pow(t, 12.0))), 0.0, 1.0);
}

// HDR version
vec3 fusionHDR(float x) {
	float t = clamp(x,0.0,1.0);
	return fusion(sqrt(t))*(0.5+2.*t);
}


//
// distance meter function. needs a bit more than just the distance
// to estimate the zoom level that it paints at.
//
// if you have real opengl, you can additionally use derivatives (dFdx, dFdy)
// to detect discontinuities, i had to strip that for webgl
//
// visualizing the magnitude of the gradient is also useful
//

vec3 distanceMeter(float dist, float rayLength, vec3 rayDir, float camHeight) {
    float idealGridDistance = 20.0/rayLength*pow(abs(rayDir.y),0.8);
    float nearestBase = floor(log(idealGridDistance)/log(10.));
    float relativeDist = abs(dist/camHeight);

    float largerDistance = pow(10.0,nearestBase+1.);
    float smallerDistance = pow(10.0,nearestBase);


    vec3 col = fusionHDR(log(1.+relativeDist));
    col = max(vec3(0.),col);
    if (sign(dist) < 0.) {
        col = col.grb*3.;
    }

    float l0 = (pow(0.5+0.5*cos(dist*PI*2.*smallerDistance),10.0));
    float l1 = (pow(0.5+0.5*cos(dist*PI*2.*largerDistance),10.0));

    float x = fract(log(idealGridDistance)/log(10.));
    l0 = mix(l0,0.,smoothstep(0.5,1.0,x));
    l1 = mix(0.,l1,smoothstep(0.0,0.5,x));

    col.rgb *= 0.1+0.9*(1.-l0)*(1.-l1);
    return col;
}







// ---------------------------


//
// float sdf_render_bak(float p) {
//   float d = p ;
//   float aa = 1.0;
//   float anti = fwidth(d) * aa;
//   return (1.0 - smoothstep(-anti, anti, d));
//   // other approach (https://github.com/Chlumsky/msdfgen/issues/22)
//   //float v = d / fwidth(d);
//   //return 1.0 - clamp( v + 0.5, 0.0, 1.0);
// }



// float sdf_render(float d, float width) {
//   float anti = fwidth(d) + width;
//   return (1.0 - smoothstep(-anti, anti, d));
// }
//


// ----------------------------------------


float packColor(vec3 color) {
    return color.r + color.g * 256.0 + color.b * 256.0 * 256.0;
}

vec3 unpackColor(float f) {
    vec3 color;
    color.r = floor(f / 256.0 / 256.0);
    color.g = floor((f - color.r * 256.0 * 256.0) / 256.0);
    color.b = floor(f - color.r * 256.0 * 256.0 - color.g * 256.0);
    return color / 255.0;
}



int newIDLayer (float a, int i) {
    return (a <= 0.0) ? i : 0;
}

float newIDLayer (float a, float i) {
    return (a <= 0.0) ? i : 0.0;
}



vec4 bbox_new (float w, float h) {
    return vec4(-w, -h, w, h);
}



vec4 bbox_grow (float d, vec4 bbox) {
    return bbox + vec4(-d,-d,d,d);
}



//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// FIXME: glslify renames functions, so we cannot concat outputs after running glslify!!!
// #pragma glslify: toLinear = require('glsl-gamma/in')
// #pragma glslify: toGamma  = require('glsl-gamma/out')

float gm = 2.2;
vec3 toGamma(vec3 v) {
  return pow(v, vec3(1.0 / gm));
}

vec4 toGamma(vec4 v) {
  return vec4(toGamma(v.rgb), v.a);
}

vec3 toLinear(vec3 v) {
  return pow(v, vec3(gm));
}

vec4 toLinear(vec4 v) {
  return vec4(toLinear(v.rgb), v.a);
}


const vec3 wref =  vec3(1.0, 1.0, 1.0);

float sRGB(float t){ return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }


vec4 rgb_init (vec4 color) {
    color.rgb *= color.a;
    return color;
}


vec4 alpha_unpremultiply (vec4 color) {
    color.rgb /= color.a;
    return color;
}

vec4 alpha_premultiply (vec4 color) {
    color.rgb *= color.a;
    return color;
}


vec4 color_init (float density, vec4 color) {
    color.a *= density;
    return alpha_premultiply(color);
}









// int id_union        (float a, float b, int ida, int idb) { return (b <= 0.0) ? idb : ida; }
// int id_difference   (float a, float b, int ida)          { return (sdf_difference(a,b) <= 0.0) ? ida : 0 ; }
// int id_intersection (float a, float b, int ida)          
//   { return ((a <= 0.0) && (b <= 0.0)) ? ida : 0 ; }


////////////////////////////////////////////////////////////////////////////////
// Shape ///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct shape {
  sdf   sdf;
  float density;
  int   id;
  vec4  color;
};


////////////////////////////////////////////////////////////////////////////////
// ID //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int id_union (shape s1, shape s2) {
    return (s2.sdf.distance <= 0.0) ? s1.id : s2.id;
}

int id_discardOutside (float distance, int id) { 
    return (distance <= 0.0) ? id : 0;
}



////////////////////////////////////////////////////////////////////////////////
// Colors //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

vec4 color_merge (shape s1, shape s2) {
    float maxDensity        = clamp(s1.density + s2.density);
    float interpolateSwitch = 1.0 - sign(maxDensity); 
    maxDensity += interpolateSwitch; // Removing division by 0
    float normDensity1 = s1.density / maxDensity;
    float normDensity2 = s2.density / maxDensity;
    vec4  color1       = s1.color * normDensity1;
    vec4  color2       = s2.color * normDensity2;
    vec4  insideColor  = color2 + (1.0 - color2.a) * color1;  
    float border       = sdf_render(s1.sdf.distance - s2.sdf.distance);
    vec4  outsideColor = mix(s2.color, s1.color, border);
    vec4  color        = mix(insideColor, outsideColor, interpolateSwitch);
    return color;
}


////////////////////////////////////////////////////////////////////////////////
// Shapes //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

shape new (int id, sdf s) {
    float density = sdf_render(s);
    vec4  color   = toLinear(vec4(1.0,0.0,0.0,1.0));
    return shape(s, density, id, color);    
}

shape new (sdf s) {
    float density = sdf_render(s);
    vec4  color   = toLinear(vec4(1.0,0.0,0.0,1.0));
    int   id      = 0;
    return shape(s, density, id, color);    
}

shape setID (shape s, int id) {
    s.id = id;
    return s;
}

shape fill (shape s, vec4 newColor) {
    vec4 color = alpha_premultiply(toLinear(newColor));
    s.color = color;
    return s;
}

shape grow (shape s, float width) {
    s.sdf.distance -= width;
    s.density   = sdf_render(s.sdf);
    return s;
}

shape union (shape s1, shape s2) {
    sdf newShape   = union(s1.sdf, s2.sdf);
    float density  = sdf_render(newShape);
    vec4  color    = color_merge(s1, s2);
    int   id       = id_union(s1,s2);
    return shape(newShape, density, id, color);
}

shape difference (shape s1, shape s2) {
    sdf newShape = difference(s1.sdf, s2.sdf);
    float density  = sdf_render(newShape);
    int   id       = id_discardOutside(newShape.distance, s1.id);
    return shape(newShape, density, id, s1.color);
}

shape intersection (shape s1, shape s2) {
    sdf newShape = intersection(s1.sdf, s2.sdf);
    float density  = sdf_render(newShape);
    int   id       = id_discardOutside(newShape.distance, s1.id);
    return shape(newShape, density, id, s1.color);
}


// hull fill (hull a, vec4 newColor) {
//   return a;
// }

hull union (hull a, hull b) {
  return hull(max(a.distance,b.distance));
}


// hull grow ($f, vec2 origin, vec2 direction, float offset) {
//     offset += radius;
//     return grow($f(origin,direction,offset), radius);
// }
// ray2
// #define CONVEX_HULL_TRANS(NAME,F) hull NAME (vec2 origin, vec2 direction, float offset) {F} 







////////////////////////////////////////////////////////////////////////////////
// Primitive Shapes Generators /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define RECTANGLE(...) PRIM(rectangle,...) 
#define PLANE(...)     PRIM(plane,...)



////////////////////////////////////////////////////////////////////////////////
// Shapes Transforms ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define MOVE(TARGET,SOURCE,...)                                                \
SHAPE_TRANS(TARGET, MOVE_SHAPE(SOURCE,...))                                    \
CONVEX_HULL_TRANS(TARGET, MOVE_CONVEX_HULL(SOURCE,...))                           
#define MOVE_SHAPE(SOURCE,...)                                                 \
  vec2 tx = vec2(...);                                                         \
  origin = sdf_translate(origin,tx);                                           \
  return SHAPE(SOURCE);                                                   
#define MOVE_CONVEX_HULL(SOURCE,...)                                           \
  vec2 tx = vec2(...);                                                         \
  origin  = sdf_translate(origin,tx);                                          \
  ray.direction = sdf_translate(ray.direction,tx);                                         \
  return CONVEX_HULL(SOURCE);                                             

#define ROTATE(TARGET,SOURCE,ANGLE)                                            \
SHAPE_TRANS(TARGET,                                                            \
  origin = sdf_rotate(origin,ANGLE);                                           \
  return SHAPE(SOURCE);)                                                                              \
CONVEX_HULL_TRANS(TARGET,                                                      \
  origin = sdf_rotate(origin,ANGLE);                                           \
  ray.direction = sdf_rotate(ray.direction,ANGLE);                                         \
  return CONVEX_HULL(SOURCE);)

#define ALIGN(TARGET,SOURCE,...)                                               \
SHAPE_TRANS(TARGET, ALIGN_SHAPE(SOURCE,...))                                   \
CONVEX_HULL_TRANS(TARGET, ALIGN_CONVEX_HULL_1(SOURCE,...))
#define ALIGN_COMMON(SOURCE,...)                                               \
  vec2 _dir            = normalize(alignDir(...));                             \
  ray2 _ray = ray2(_dir, 0.0);                           \
  vec2 _tx             = -SOURCE(vec2(0.0), _ray).distance * _dir;
#define ALIGN_SHAPE(SOURCE,...)                                                \
  ALIGN_COMMON(SOURCE,...)                                                     \
  MOVE_SHAPE(SOURCE,_tx)
#define ALIGN_CONVEX_HULL(SOURCE,...)                                          \
  ALIGN_COMMON(SOURCE,...)                                                     \
  MOVE_CONVEX_HULL(SOURCE,_tx)


////////////////////////////////////////////////////////////////////////////////
// Shapes Modifiers ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define DIFFERENCE(...)   SIMPLE_SHAPE_MODIFIER2(difference,...)
#define INTERSECTION(...) SIMPLE_MODIFIER2(intersection,...)
#define FILL(...)         SIMPLE_SHAPE_MODIFIER1(fill,...)
#define UNION(...)        SIMPLE_MODIFIER2(overloaded_union,...)

#define GROW(TARGET,SOURCE,RADIUS)                                             \
SHAPE_TRANS(TARGET, return grow(SHAPE(SOURCE),RADIUS);)                        \
CONVEX_HULL_TRANS(TARGET, ray.offset += RADIUS; return CONVEX_HULL(SOURCE);)





// #define GROW_DEF(TARGET,SOURCE,...)                                            \
// SHAPE_TRANS(TARGET,                                                              \
//   return grow(SHAPE(SOURCE),...);                                         \
// )                                                                              \
// CONVEX_HULL_TRANS(TARGET,                                                        \
//   offset += ...;                                                               \
//   return grow(CONVEX_HULL(SOURCE),...);                                   \
// )


// #define MOVE_SHAPE(SOURCE,...)                                                 \
//   vec2 tx = vec2(...);                                                         \
//   origin  = sdf_translate(origin,tx);                                          \
//   return SHAPE(SOURCE);                                                   \

// #define MOVE_CONVEX_HULL(SOURCE,...)                                           \
//   vec2 tx = vec2(...);                                                         \
//   origin  = sdf_translate(origin,tx);                                          \
//   direction     = sdf_translate(direction,tx);                                             \
//   return CONVEX_HULL(SOURCE);                                             \

// #define MOVE_DEF(TARGET,SOURCE,...)                                            \
// SHAPE_TRANS(TARGET, MOVE_SHAPE(SOURCE,...))                                      \
// CONVEX_HULL_TRANS(TARGET, MOVE_CONVEX_HULL(SOURCE,...))                           



// #define ALIGN_COMMON(SOURCE,...)                                               \
//   vec2 _dir = normalize(alignDir(...));                                        \
//   vec2 _tx  = -SOURCE(vec2(0.0), _dir, 0.0).distance * _dir;                   

// #define ALIGN_SHAPE(SOURCE,...)                                                \
//   ALIGN_COMMON(SOURCE...)                                                      \
//   MOVE_SHAPE_1(SOURCE,_tx)

// #define ALIGN_CONVEX_HULL(SOURCE,...)                                          \
//   ALIGN_COMMON(SOURCE...)                                                      \
//   MOVE_CONVEX_HULL_1(SOURCE,_tx)

// #define ALIGN_DEF(TARGET,SOURCE,...)                                           \
// SHAPE_TRANS(TARGET, ALIGN_SHAPE(SOURCE,...))                                     \
// CONVEX_HULL_TRANS(TARGET, ALIGN_CONVEX_HULL(SOURCE,...))






// growXX(shape_3,shape_2,11.0);

vec2 alignDir (vec2 a) {
    return a;
}

vec2 alignDir () {
    return vec2(0.0,-1.0);
}

vec2 alignDir (float x, float y) {
    return vec2(x,y);
}



// //-----------------Lch-----------------

// float xyzF(float t){ return mix(pow(t,1./3.), 7.787037*t + 0.139731, step(t,0.00885645)); }
// float xyzR(float t){ return mix(t*t*t , 0.1284185*(t - 0.139731), step(t,0.20689655)); }
// vec3 rgb2lch(in vec3 c)
// {
// 	c  *= mat3( 0.4124, 0.3576, 0.1805,
//           		0.2126, 0.7152, 0.0722,
//                 0.0193, 0.1192, 0.9505);
//     c.x = xyzF(c.x/wref.x);
// 	c.y = xyzF(c.y/wref.y);
// 	c.z = xyzF(c.z/wref.z);
// 	vec3 lab = vec3(max(0.,116.0*c.y - 16.0), 500.0*(c.x - c.y), 200.0*(c.y - c.z));
//     return vec3(lab.x, length(vec2(lab.y,lab.z)), atan(lab.z, lab.y));
// }

// vec4 rgb2lch(vec4 c) {
//     return vec4(rgb2lch(c.rgb), c.a);
// }
// vec3 hue2rgb(float hue) {
//     float R = abs(hue * 6.0 - 3.0) - 1.0;
//     float G = 2.0 - abs(hue * 6.0 - 2.0);
//     float B = 2.0 - abs(hue * 6.0 - 4.0);
//     return clamp(vec3(R,G,B), 0.0, 1.0);
// }
// vec3 hsl2rgb(vec3 hsl) {
//     vec3 rgb = hue2rgb(hsl.x);
//     float C = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
//     return (rgb - 0.5) * C + hsl.z;
// }
// vec3 hsl2lch(vec3 c) {
//     return rgb2lch(hsl2rgb(c));
// }
// vec4 hsl2lch(vec4 c) {
//     return vec4(hsl2lch(c.xyz), c.a);
// }

// vec3 lch2rgb(in vec3 c)
// {
//     c = vec3(c.x, cos(c.z) * c.y, sin(c.z) * c.y);

//     float lg = 1./116.*(c.x + 16.);
//     vec3 xyz = vec3(wref.x*xyzR(lg + 0.002*c.y),
//     				wref.y*xyzR(lg),
//     				wref.z*xyzR(lg - 0.005*c.z));

//     vec3 rgb = xyz*mat3( 3.2406, -1.5372,-0.4986,
//           		        -0.9689,  1.8758, 0.0415,
//                 	     0.0557,  -0.2040, 1.0570);

//     return rgb;
// }

// //cheaply lerp around a circle
// float lerpAng(in float a, in float b, in float x)
// {
//     float ang = mod(mod((a-b), TAU) + PI*3., TAU)-PI;
//     return ang*x+b;
// }

// //Linear interpolation between two colors in Lch space
// vec3 lerpLch(in vec3 a, in vec3 b, in float x)
// {
//     float hue = lerpAng(a.z, b.z, x);
//     return vec3(mix(b.xy, a.xy, x), hue);
// }









// // FIXME: fix transparent aa - fwidth is obsolete now, see sdf_render for reference
// vec4 color_mergeLCH (float d2, float d1, vec4 c2, vec4 c1, float width) {
//   float w1  = width + fwidth(d1);
//   float w2  = width + fwidth(d2);
//   float p1  = sdf_render(d1);
//   float p2  = sdf_render(d2);
//   float pb1 = c1.a * c1.a * smoothstep(1.0-clamp((d1/w1) + 0.5));
//   float pb2 = c2.a * c2.a * smoothstep(1.0-clamp((d2/w2)));
//   vec3  c3  = mix (c1.rgb, pb1, c2.rgb, (1.0-pb1)*pb2);
//   float aa  = p1 * c1.a + p2 * c2.a;
//   aa /= max(p1, p2); // unpremultiply
//   return vec4(c3, aa);
// }

// // vec3 color_mergeLCH (float d1, float d2, vec3 c1, vec3 c2, float width) {
// //   float w1  = width + fwidth(d1);
// //   float w2  = width + fwidth(d2);
// //   float pb1 = smoothstep(1.0-clamp((d1/w1) + 0.5));
// //   float pb2 = smoothstep(1.0-clamp((d2/w2)));
// //   vec3  c3  = mix (c1, pb1, c2, (1.0-pb1)*pb2);
// //   return c3;
// // }

// vec4 color_mergeLCH (float d1, float d2, vec4 c1, vec4 c2) {
//     return color_mergeLCH(d1, d2, c1, c2, 0.0);
// }

// vec3 color_mergeLCH (float d1, float d2, vec3 c1, vec3 c2) {
//     return color_mergeLCH(d1, d2, c1, c2, 0.0);
// }





void convert (inout int   outp, int inp) { outp = int(inp)   ; }
void convert (inout float outp, int inp) { outp = float(inp) ; }
void convert (inout vec2  outp, int inp) { outp = vec2(inp)  ; }
void convert (inout vec3  outp, int inp) { outp = vec3(inp)  ; }
void convert (inout vec4  outp, int inp) { outp = vec4(inp)  ; }
void convert (inout ivec2 outp, int inp) { outp = ivec2(inp) ; }
void convert (inout ivec3 outp, int inp) { outp = ivec3(inp) ; }
void convert (inout ivec4 outp, int inp) { outp = ivec4(inp) ; }

void convert (inout int   outp, float inp) { outp = int(inp)   ; }
void convert (inout float outp, float inp) { outp = float(inp) ; }
void convert (inout vec2  outp, float inp) { outp = vec2(inp)  ; }
void convert (inout vec3  outp, float inp) { outp = vec3(inp)  ; }
void convert (inout vec4  outp, float inp) { outp = vec4(inp)  ; }
void convert (inout ivec2 outp, float inp) { outp = ivec2(inp) ; }
void convert (inout ivec3 outp, float inp) { outp = ivec3(inp) ; }
void convert (inout ivec4 outp, float inp) { outp = ivec4(inp) ; }

void convert (inout int   outp, vec2 inp) { outp = int(inp)          ; }
void convert (inout float outp, vec2 inp) { outp = float(inp)        ; }
void convert (inout vec2  outp, vec2 inp) { outp = vec2(inp)         ; }
void convert (inout vec3  outp, vec2 inp) { outp = vec3(inp,0.0)     ; }
void convert (inout vec4  outp, vec2 inp) { outp = vec4(inp,0.0,0.0) ; }
void convert (inout ivec2 outp, vec2 inp) { outp = ivec2(inp)        ; }
void convert (inout ivec3 outp, vec2 inp) { outp = ivec3(inp,0)      ; }
void convert (inout ivec4 outp, vec2 inp) { outp = ivec4(inp,0,0)    ; }

void convert (inout int   outp, vec3 inp) { outp = int(inp)      ; }
void convert (inout float outp, vec3 inp) { outp = float(inp)    ; }
void convert (inout vec2  outp, vec3 inp) { outp = vec2(inp)     ; }
void convert (inout vec3  outp, vec3 inp) { outp = vec3(inp)     ; }
void convert (inout vec4  outp, vec3 inp) { outp = vec4(inp,0.0) ; }
void convert (inout ivec2 outp, vec3 inp) { outp = ivec2(inp)    ; }
void convert (inout ivec3 outp, vec3 inp) { outp = ivec3(inp)    ; }
void convert (inout ivec4 outp, vec3 inp) { outp = ivec4(inp,0)  ; }

void convert (inout int   outp, vec4 inp) { outp = int(inp)   ; }
void convert (inout float outp, vec4 inp) { outp = float(inp) ; }
void convert (inout vec2  outp, vec4 inp) { outp = vec2(inp)  ; }
void convert (inout vec3  outp, vec4 inp) { outp = vec3(inp)  ; }
void convert (inout vec4  outp, vec4 inp) { outp = vec4(inp)  ; }
void convert (inout ivec2 outp, vec4 inp) { outp = ivec2(inp) ; }
void convert (inout ivec3 outp, vec4 inp) { outp = ivec3(inp) ; }
void convert (inout ivec4 outp, vec4 inp) { outp = ivec4(inp) ; }

void convert (inout int   outp, ivec2 inp) { outp = int(inp)          ; }
void convert (inout float outp, ivec2 inp) { outp = float(inp)        ; }
void convert (inout vec2  outp, ivec2 inp) { outp = vec2(inp)         ; }
void convert (inout vec3  outp, ivec2 inp) { outp = vec3(inp,0.0)     ; }
void convert (inout vec4  outp, ivec2 inp) { outp = vec4(inp,0.0,0.0) ; }
void convert (inout ivec2 outp, ivec2 inp) { outp = ivec2(inp)        ; }
void convert (inout ivec3 outp, ivec2 inp) { outp = ivec3(inp,0)      ; }
void convert (inout ivec4 outp, ivec2 inp) { outp = ivec4(inp,0,0)    ; }

void convert (inout int   outp, ivec3 inp) { outp = int(inp)      ; }
void convert (inout float outp, ivec3 inp) { outp = float(inp)    ; }
void convert (inout vec2  outp, ivec3 inp) { outp = vec2(inp)     ; }
void convert (inout vec3  outp, ivec3 inp) { outp = vec3(inp)     ; }
void convert (inout vec4  outp, ivec3 inp) { outp = vec4(inp,0.0) ; }
void convert (inout ivec2 outp, ivec3 inp) { outp = ivec2(inp)    ; }
void convert (inout ivec3 outp, ivec3 inp) { outp = ivec3(inp)    ; }
void convert (inout ivec4 outp, ivec3 inp) { outp = ivec4(inp,0)  ; }

void convert (inout int   outp, ivec4 inp) { outp = int(inp)   ; }
void convert (inout float outp, ivec4 inp) { outp = float(inp) ; }
void convert (inout vec2  outp, ivec4 inp) { outp = vec2(inp)  ; }
void convert (inout vec3  outp, ivec4 inp) { outp = vec3(inp)  ; }
void convert (inout vec4  outp, ivec4 inp) { outp = vec4(inp)  ; }
void convert (inout ivec2 outp, ivec4 inp) { outp = ivec2(inp) ; }
void convert (inout ivec3 outp, ivec4 inp) { outp = ivec3(inp) ; }
void convert (inout ivec4 outp, ivec4 inp) { outp = ivec4(inp) ; }
