#define DECLARE_CCTK_PARAMETERS \
CCTK_DECLARE(CCTK_REAL,dx,)&&\
CCTK_DECLARE(CCTK_REAL,dy,)&&\
CCTK_DECLARE(CCTK_REAL,dz,)&&\
CCTK_DECLARE(CCTK_REAL,xextent,)&&\
CCTK_DECLARE(CCTK_REAL,xmax,)&&\
CCTK_DECLARE(CCTK_REAL,xmin,)&&\
CCTK_DECLARE(CCTK_REAL,yextent,)&&\
CCTK_DECLARE(CCTK_REAL,ymax,)&&\
CCTK_DECLARE(CCTK_REAL,ymin,)&&\
CCTK_DECLARE(CCTK_REAL,zextent,)&&\
CCTK_DECLARE(CCTK_REAL,zmax,)&&\
CCTK_DECLARE(CCTK_REAL,zmin,)&&\
CCTK_DECLARE(CCTK_STRING,domainsize,)&&\
CCTK_DECLARE(CCTK_STRING,spacing,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_x_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_x_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_y_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_y_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_z_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_internal_z_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_x_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_x_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_y_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_y_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_z_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_shiftout_z_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_x_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_x_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_y_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_y_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_z_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_size_z_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_x_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_x_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_y_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_y_upper,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_z_lower,)&&\
CCTK_DECLARE(CCTK_INT,boundary_staggered_z_upper,)&&\
CCTK_DECLARE(CCTK_INT,ncells_x,)&&\
CCTK_DECLARE(CCTK_INT,ncells_y,)&&\
CCTK_DECLARE(CCTK_INT,ncells_z,)&&\
CCTK_DECLARE(CCTK_INT,zero_origin_x,)&&\
CCTK_DECLARE(CCTK_INT,zero_origin_y,)&&\
CCTK_DECLARE(CCTK_INT,zero_origin_z,)&&\
COMMON /CoordBasepriv/dx, dy, dz, xextent, xmax, xmin, yextent, ymax, ymin, zextent, zmax, zmin, domainsize, spacing, boundary_internal_x_lower, boundary_internal_x_upper, boundary_internal_y_lower, boundary_internal_y_upper, boundary_internal_z_lower, boundary_internal_z_upper, boundary_shiftout_x_lower, boundary_shiftout_x_upper, boundary_shiftout_y_lower, boundary_shiftout_y_upper, boundary_shiftout_z_lower, boundary_shiftout_z_upper, boundary_size_x_lower, boundary_size_x_upper, boundary_size_y_lower, boundary_size_y_upper, boundary_size_z_lower, boundary_size_z_upper, boundary_staggered_x_lower, boundary_staggered_x_upper, boundary_staggered_y_lower, boundary_staggered_y_upper, boundary_staggered_z_lower, boundary_staggered_z_upper, ncells_x, ncells_y, ncells_z, zero_origin_x, zero_origin_y, zero_origin_z&&\

