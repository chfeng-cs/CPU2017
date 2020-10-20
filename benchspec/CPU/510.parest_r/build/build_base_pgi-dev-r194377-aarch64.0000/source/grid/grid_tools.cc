//---------------------------------------------------------------------------
//    $Id: grid_tools.cc 18246 2009-01-19 04:23:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2013 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------



#include <grid/grid_tools.h>
#include <grid/tria.h>
#include <grid/tria_accessor.h>
#include <grid/tria_iterator.h>
#include <grid/intergrid_map.h>
#include <lac/sparsity_pattern.h>
#include <lac/sparsity_tools.h>
#include <lac/compressed_sparsity_pattern.h>
#include <dofs/dof_handler.h>
#include <dofs/dof_accessor.h>
#include <dofs/dof_tools.h>
#include <fe/fe_dgq.h>
#include <fe/mapping_q1.h>
#include <hp/mapping_collection.h>
#include <multigrid/mg_dof_handler.h>
#include <multigrid/mg_dof_accessor.h>

#include <cmath>

DEAL_II_NAMESPACE_OPEN


// This anonymous namespace contains utility functions to extract the
// triangulation from any container such as DoFHandler, MGDoFHandler,
// and the like
namespace
{
    template<int dim, int spacedim>
    const Triangulation<dim, spacedim> &get_tria(const Triangulation<dim, spacedim> &tria)
   {
      return tria;
   }

    template<int dim, template<int, int> class Container, int spacedim>
    const Triangulation<dim> &get_tria(const Container<dim,spacedim> &container)
   {
      return container.get_tria();
   }
}

#if deal_II_dimension != 1

template <int dim, int spacedim>
double
GridTools::diameter (const Triangulation<dim, spacedim> &tria)
{
				   // the algorithm used simply
				   // traverses all cells and picks
				   // out the boundary vertices. it
				   // may or may not be faster to
				   // simply get all vectors, don't
				   // mark boundary vertices, and
				   // compute the distances thereof,
				   // but at least as the mesh is
				   // refined, it seems better to
				   // first mark boundary nodes, as
				   // marking is O(N) in the number of
				   // cells/vertices, while computing
				   // the maximal distance is O(N*N)
  const std::vector<Point<spacedim> > &vertices = tria.get_vertices ();
  std::vector<bool> boundary_vertices (vertices.size(), false);

  typename Triangulation<dim,spacedim>::active_cell_iterator
    cell = tria.begin_active();
  const typename Triangulation<dim,spacedim>::active_cell_iterator
    endc = tria.end();
  for (; cell!=endc; ++cell)
    for (unsigned int face=0; face<GeometryInfo<dim>::faces_per_cell; ++face)
      if (cell->face(face)->at_boundary ())
	for (unsigned int i=0; i<GeometryInfo<dim>::vertices_per_face; ++i)
	  boundary_vertices[cell->face(face)->vertex_index(i)] = true;

				   // now traverse the list of
				   // boundary vertices and check
				   // distances. since distances are
				   // symmetric, we only have to check
				   // one half
  double max_distance_sqr = 0;
  std::vector<bool>::const_iterator pi = boundary_vertices.begin();
  const unsigned int N = boundary_vertices.size();
  for (unsigned int i=0; i<N; ++i, ++pi)
    {
      std::vector<bool>::const_iterator pj = pi+1;
      for (unsigned int j=i+1; j<N; ++j, ++pj)
	if ((*pi==true) && (*pj==true) &&
	    ((vertices[i]-vertices[j]).square() > max_distance_sqr))
	  max_distance_sqr = (vertices[i]-vertices[j]).square();
    };

  return std::sqrt(max_distance_sqr);
}


#else

double
GridTools::diameter (const Triangulation<1> &tria)
{
				   // for 1d, simply check the
				   // vertices of the left- and
				   // rightmost coarse grid cell
  Triangulation<1>::cell_iterator leftmost  = tria.begin(0);
  Triangulation<1>::cell_iterator rightmost = tria.begin(0);

  while (!leftmost->at_boundary(0))  leftmost  = leftmost->neighbor(0);
  while (!rightmost->at_boundary(1)) rightmost = rightmost->neighbor(1);

  return std::sqrt((leftmost->vertex(0) - rightmost->vertex(1)).square());
}

#endif



#if deal_II_dimension == 3

template <>
double
GridTools::cell_measure<3>(const std::vector<Point<3> > &all_vertices,
			 const unsigned int (&vertex_indices)[GeometryInfo<3>::vertices_per_cell])
{
				   // note that this is the
				   // cell_measure based on the new
				   // deal.II numbering. When called
				   // from inside GridReordering make
				   // sure that you reorder the
				   // vertex_indices before
  const double x[8] = { all_vertices[vertex_indices[0]](0),
			all_vertices[vertex_indices[1]](0),
			all_vertices[vertex_indices[2]](0),
			all_vertices[vertex_indices[3]](0),
			all_vertices[vertex_indices[4]](0),
			all_vertices[vertex_indices[5]](0),
			all_vertices[vertex_indices[6]](0),
			all_vertices[vertex_indices[7]](0)   };
  const double y[8] = { all_vertices[vertex_indices[0]](1),
			all_vertices[vertex_indices[1]](1),
			all_vertices[vertex_indices[2]](1),
			all_vertices[vertex_indices[3]](1),
			all_vertices[vertex_indices[4]](1),
			all_vertices[vertex_indices[5]](1),
			all_vertices[vertex_indices[6]](1),
			all_vertices[vertex_indices[7]](1)  };
  const double z[8] = { all_vertices[vertex_indices[0]](2),
			all_vertices[vertex_indices[1]](2),
			all_vertices[vertex_indices[2]](2),
			all_vertices[vertex_indices[3]](2),
			all_vertices[vertex_indices[4]](2),
			all_vertices[vertex_indices[5]](2),
			all_vertices[vertex_indices[6]](2),
			all_vertices[vertex_indices[7]](2)  };

/*
  This is the same Maple script as in the barycenter method above
  except of that here the shape functions tphi[0]-tphi[7] are ordered
  according to the lexicographic numbering.

  x := array(0..7):
  y := array(0..7):
  z := array(0..7):
  tphi[0] := (1-xi)*(1-eta)*(1-zeta):
  tphi[1] :=     xi*(1-eta)*(1-zeta):
  tphi[2] := (1-xi)*    eta*(1-zeta):
  tphi[3] :=     xi*    eta*(1-zeta):
  tphi[4] := (1-xi)*(1-eta)*zeta:
  tphi[5] :=     xi*(1-eta)*zeta:
  tphi[6] := (1-xi)*    eta*zeta:
  tphi[7] :=     xi*    eta*zeta:
  x_real := sum(x[s]*tphi[s], s=0..7):
  y_real := sum(y[s]*tphi[s], s=0..7):
  z_real := sum(z[s]*tphi[s], s=0..7):
  with (linalg):
  J := matrix(3,3, [[diff(x_real, xi), diff(x_real, eta), diff(x_real, zeta)],
  [diff(y_real, xi), diff(y_real, eta), diff(y_real, zeta)],
  [diff(z_real, xi), diff(z_real, eta), diff(z_real, zeta)]]): 
  detJ := det (J):

  measure := simplify ( int ( int ( int (detJ, xi=0..1), eta=0..1), zeta=0..1)):

  readlib(C):

  C(measure, optimized);

  The C code produced by this maple script is further optimized by
  hand. In particular, division by 12 is performed only once, not
  hundred of times.
*/

  const double t3 = y[3]*x[2];
  const double t5 = z[1]*x[5];
  const double t9 = z[3]*x[2];
  const double t11 = x[1]*y[0];
  const double t14 = x[4]*y[0];
  const double t18 = x[5]*y[7];
  const double t20 = y[1]*x[3];
  const double t22 = y[5]*x[4];
  const double t26 = z[7]*x[6];
  const double t28 = x[0]*y[4];
  const double t34 = z[3]*x[1]*y[2]+t3*z[1]-t5*y[7]+y[7]*x[4]*z[6]+t9*y[6]-t11*z[4]-t5*y[3]-t14*z[2]+z[1]*x[4]*y[0]-t18*z[3]+t20*z[0]-t22*z[0]-y[0]*x[5]*z[4]-t26*y[3]+t28*z[2]-t9*y[1]-y[1]*x[4]*z[0]-t11*z[5];
  const double t37 = y[1]*x[0];
  const double t44 = x[1]*y[5];
  const double t46 = z[1]*x[0];
  const double t49 = x[0]*y[2];
  const double t52 = y[5]*x[7];
  const double t54 = x[3]*y[7];
  const double t56 = x[2]*z[0];
  const double t58 = x[3]*y[2];
  const double t64 = -x[6]*y[4]*z[2]-t37*z[2]+t18*z[6]-x[3]*y[6]*z[2]+t11*z[2]+t5*y[0]+t44*z[4]-t46*y[4]-t20*z[7]-t49*z[6]-t22*z[1]+t52*z[3]-t54*z[2]-t56*y[4]-t58*z[0]+y[1]*x[2]*z[0]+t9*y[7]+t37*z[4];
  const double t66 = x[1]*y[7];
  const double t68 = y[0]*x[6];
  const double t70 = x[7]*y[6];
  const double t73 = z[5]*x[4];
  const double t76 = x[6]*y[7];
  const double t90 = x[4]*z[0];
  const double t92 = x[1]*y[3];
  const double t95 = -t66*z[3]-t68*z[2]-t70*z[2]+t26*y[5]-t73*y[6]-t14*z[6]+t76*z[2]-t3*z[6]+x[6]*y[2]*z[4]-z[3]*x[6]*y[2]+t26*y[4]-t44*z[3]-x[1]*y[2]*z[0]+x[5]*y[6]*z[4]+t54*z[5]+t90*y[2]-t92*z[2]+t46*y[2];
  const double t102 = x[2]*y[0];
  const double t107 = y[3]*x[7];
  const double t114 = x[0]*y[6];
  const double t125 = y[0]*x[3]*z[2]-z[7]*x[5]*y[6]-x[2]*y[6]*z[4]+t102*z[6]-t52*z[6]+x[2]*y[4]*z[6]-t107*z[5]-t54*z[6]+t58*z[6]-x[7]*y[4]*z[6]+t37*z[5]-t114*z[4]+t102*z[4]-z[1]*x[2]*y[0]+t28*z[6]-y[5]*x[6]*z[4]-z[5]*x[1]*y[4]-t73*y[7];
  const double t129 = z[0]*x[6];
  const double t133 = y[1]*x[7];
  const double t145 = y[1]*x[5];
  const double t156 = t90*y[6]-t129*y[4]+z[7]*x[2]*y[6]-t133*z[5]+x[5]*y[3]*z[7]-t26*y[2]-t70*z[3]+t46*y[3]+z[5]*x[7]*y[4]+z[7]*x[3]*y[6]-t49*z[4]+t145*z[7]-x[2]*y[7]*z[6]+t70*z[5]+t66*z[5]-z[7]*x[4]*y[6]+t18*z[4]+x[1]*y[4]*z[0];
  const double t160 = x[5]*y[4];
  const double t165 = z[1]*x[7];
  const double t178 = z[1]*x[3];
  const double t181 = t107*z[6]+t22*z[7]+t76*z[3]+t160*z[1]-x[4]*y[2]*z[6]+t70*z[4]+t165*y[5]+x[7]*y[2]*z[6]-t76*z[5]-t76*z[4]+t133*z[3]-t58*z[1]+y[5]*x[0]*z[4]+t114*z[2]-t3*z[7]+t20*z[2]+t178*y[7]+t129*y[2];
  const double t207 = t92*z[7]+t22*z[6]+z[3]*x[0]*y[2]-x[0]*y[3]*z[2]-z[3]*x[7]*y[2]-t165*y[3]-t9*y[0]+t58*z[7]+y[3]*x[6]*z[2]+t107*z[2]+t73*y[0]-x[3]*y[5]*z[7]+t3*z[0]-t56*y[6]-z[5]*x[0]*y[4]+t73*y[1]-t160*z[6]+t160*z[0];
  const double t228 = -t44*z[7]+z[5]*x[6]*y[4]-t52*z[4]-t145*z[4]+t68*z[4]+t92*z[5]-t92*z[0]+t11*z[3]+t44*z[0]+t178*y[5]-t46*y[5]-t178*y[0]-t145*z[0]-t20*z[5]-t37*z[3]-t160*z[7]+t145*z[3]+x[4]*y[6]*z[2];

  return (t34+t64+t95+t125+t156+t181+t207+t228)/12.;
}

#endif

#if deal_II_dimension == 2


template <>
double
GridTools::cell_measure(const std::vector<Point<2> > &all_vertices,
			const unsigned int (&vertex_indices) [GeometryInfo<2>::vertices_per_cell])
{
/*
  Get the computation of the measure by this little Maple script. We
  use the blinear mapping of the unit quad to the real quad. However,
  every transformation mapping the unit faces to straight lines should
  do.

  Remember that the area of the quad is given by
  \int_K 1 dx dy  = \int_{\hat K} |det J| d(xi) d(eta)

  # x and y are arrays holding the x- and y-values of the four vertices
  # of this cell in real space. 
  x := array(0..3);
  y := array(0..3);
  z := array(0..3);
  tphi[0] := (1-xi)*(1-eta):
  tphi[1] :=     xi*(1-eta):
  tphi[2] := (1-xi)*eta:
  tphi[3] :=     xi*eta:
  x_real := sum(x[s]*tphi[s], s=0..3):
  y_real := sum(y[s]*tphi[s], s=0..3):
  z_real := sum(z[s]*tphi[s], s=0..3):
  
  Jxi := <diff(x_real,xi)  | diff(y_real,xi) | diff(z_real,xi)>;
  Jeta := <diff(x_real,eta)| diff(y_real,eta)| diff(z_real,eta)>;
  with(VectorCalculus):  
  J := CrossProduct(Jxi, Jeta);
  detJ := sqrt(J[1]^2 + J[2]^2 +J[3]^2);

  # measure := evalf (Int (Int (detJ, xi=0..1, method = _NCrule ) , eta=0..1, method = _NCrule  ) ):
  # readlib(C):

  # C(measure, optimized);

  additional optimizaton: divide by 2 only one time
*/

  const double x[4] = { all_vertices[vertex_indices[0]](0),
			all_vertices[vertex_indices[1]](0),
			all_vertices[vertex_indices[2]](0),
			all_vertices[vertex_indices[3]](0)};

  const double y[4] = { all_vertices[vertex_indices[0]](1),
			all_vertices[vertex_indices[1]](1),
			all_vertices[vertex_indices[2]](1),
			all_vertices[vertex_indices[3]](1)};

  return (-x[1]*y[0]+x[1]*y[3]+y[0]*x[2]+x[0]*y[1]-x[0]*y[2]-y[1]*x[3]-x[2]*y[3]+x[3]*y[2])/2;

}

#endif


template <int dim>
double
GridTools::cell_measure(const std::vector<Point<dim> > &,
			const unsigned int (&) [1 << dim])
{
  Assert(false, ExcNotImplemented());
  return 0.;
}



template <int dim, int spacedim>
void
GridTools::delete_unused_vertices (std::vector<Point<spacedim> >    &vertices,
				   std::vector<CellData<dim> > &cells,
				   SubCellData                 &subcelldata)
{
				   // first check which vertices are
				   // actually used
  std::vector<bool> vertex_used (vertices.size(), false);
  for (unsigned int c=0; c<cells.size(); ++c)
    for (unsigned int v=0; v<GeometryInfo<dim>::vertices_per_cell; ++v)
      vertex_used[cells[c].vertices[v]] = true;

				   // then renumber the vertices that
				   // are actually used in the same
				   // order as they were beforehand
  const unsigned int invalid_vertex = numbers::invalid_unsigned_int;
  std::vector<unsigned int> new_vertex_numbers (vertices.size(), invalid_vertex);
  unsigned int next_free_number = 0;
  for (unsigned int i=0; i<vertices.size(); ++i)
    if (vertex_used[i] == true)
      {
	new_vertex_numbers[i] = next_free_number;
	++next_free_number;
      };

				   // next replace old vertex numbers
				   // by the new ones
  for (unsigned int c=0; c<cells.size(); ++c)
    for (unsigned int v=0; v<GeometryInfo<dim>::vertices_per_cell; ++v)
      cells[c].vertices[v] = new_vertex_numbers[cells[c].vertices[v]];

				   // same for boundary data
  for (unsigned int c=0; c<subcelldata.boundary_lines.size(); ++c)
    for (unsigned int v=0; v<GeometryInfo<1>::vertices_per_cell; ++v)
      subcelldata.boundary_lines[c].vertices[v]
	= new_vertex_numbers[subcelldata.boundary_lines[c].vertices[v]];
  for (unsigned int c=0; c<subcelldata.boundary_quads.size(); ++c)
    for (unsigned int v=0; v<GeometryInfo<2>::vertices_per_cell; ++v)
      subcelldata.boundary_quads[c].vertices[v]
	= new_vertex_numbers[subcelldata.boundary_quads[c].vertices[v]];

				   // finally copy over the vertices
				   // which we really need to a new
				   // array and replace the old one by
				   // the new one
  std::vector<Point<spacedim> > tmp;
  tmp.reserve (std::count(vertex_used.begin(), vertex_used.end(), true));
  for (unsigned int v=0; v<vertices.size(); ++v)
    if (vertex_used[v] == true)
      tmp.push_back (vertices[v]);
  swap (vertices, tmp);
}



template <int dim, int spacedim>
void
GridTools::delete_duplicated_vertices (std::vector<Point<spacedim> >    &vertices,
				       std::vector<CellData<dim> > &cells,
				       SubCellData                 &subcelldata,
				       std::vector<unsigned int>   &considered_vertices,
				       double                       tol)
{
				   // create a vector of vertex
				   // indices. initialize it to the identity,
				   // later on change that if necessary.
  std::vector<unsigned int> new_vertex_numbers(vertices.size());
  for (unsigned int i=0; i<vertices.size(); ++i)
    new_vertex_numbers[i]=i;

				   // if the considered_vertices vector is
				   // empty, consider all vertices
  if (considered_vertices.size()==0)
    considered_vertices=new_vertex_numbers;

				   // now loop over all vertices to be
				   // considered and try to find an identical
				   // one
  for (unsigned int i=0; i<considered_vertices.size(); ++i)
    {
      if (new_vertex_numbers[considered_vertices[i]]!=considered_vertices[i])
					 // this vertex has been identified with
					 // another one already, skip it in the
					 // test
	continue;
				       // this vertex is not identified with
				       // another one so far. search in the list
				       // of remaining vertices. if a duplicate
				       // vertex is found, set the new vertex
				       // index for that vertex to this vertex'
				       // index.
      for (unsigned int j=i+1; j<considered_vertices.size(); ++j)
	{
	  bool equal=true;
	  for (unsigned int d=0; d<dim; ++d)
        equal &= (std::fabs(vertices[considered_vertices[j]](d)-vertices[considered_vertices[i]](d))<tol);
	  if (equal)
	    {
	      new_vertex_numbers[considered_vertices[j]]=considered_vertices[i];
	      // we do not suppose, that there might be another duplicate
	      // vertex, so break here
	      break;
	    }
	}		
    }

				   // now we got a renumbering list. simply
				   // renumber all vertices (non-duplicate
				   // vertices get renumbered to themselves, so
				   // nothing bad happens). after that, the
				   // duplicate vertices will be unused, so call
				   // delete_unused_vertices() to do that part
				   // of the job.
  for (unsigned int c=0; c<cells.size(); ++c)
    for (unsigned int v=0; v<GeometryInfo<dim>::vertices_per_cell; ++v)
      cells[c].vertices[v]=new_vertex_numbers[cells[c].vertices[v]];

  delete_unused_vertices(vertices,cells,subcelldata);
}



// define some transformations in an anonymous namespace
#ifdef DEAL_II_ANON_NAMESPACE_BOGUS_WARNING
  namespace TRANS
#else
  namespace
#endif
{
  template <int spacedim>
  class ShiftPoint
  {
    public:
      ShiftPoint (const Point<spacedim> &shift)
		      :
		      shift(shift)
	{}
      Point<spacedim> operator() (const Point<spacedim> p) const
	{
	  return p+shift;
	}
    private:
      const Point<spacedim> shift;
  };


                                   // the following class is only
                                   // needed in 2d, so avoid trouble
                                   // with compilers warning otherwise
#if deal_II_dimension == 2
  class Rotate2d
  {
    public:
      Rotate2d (const double angle)
		      :
		      angle(angle)
	{}
      Point<2> operator() (const Point<2> p) const
	{
	  return Point<2> (std::cos(angle)*p(0) - std::sin(angle) * p(1),
			   std::sin(angle)*p(0) + std::cos(angle) * p(1));
	}
    private:
      const double angle;
  };
#endif


  template <int spacedim>
  class ScalePoint
  {
    public:
      ScalePoint (const double factor)
		      :
		      factor(factor)
	{}
      Point<spacedim> operator() (const Point<spacedim> p) const
	{
	  return p*factor;
	}
    private:
      const double factor;
  };
}


template <int dim, int spacedim>
void
GridTools::shift (const Point<spacedim>   &shift_vector,
		  Triangulation<dim, spacedim> &triangulation)
{
#ifdef DEAL_II_ANON_NAMESPACE_BOGUS_WARNING
  transform (TRANS::ShiftPoint<spacedim>(shift_vector), triangulation);
#else
  transform (ShiftPoint<spacedim>(shift_vector), triangulation);
#endif  
}


#if deal_II_dimension == 2

void
GridTools::rotate (const double      angle,
		   Triangulation<2> &triangulation)
{
#ifdef DEAL_II_ANON_NAMESPACE_BOGUS_WARNING
  transform (TRANS::Rotate2d(angle), triangulation);
#else
  transform (Rotate2d(angle), triangulation);
#endif  
}

#endif


template <int dim, int spacedim>
void
GridTools::scale (const double        scaling_factor,
		  Triangulation<dim, spacedim> &triangulation)
{
  Assert (scaling_factor>0, ExcScalingFactorNotPositive (scaling_factor));
#ifdef DEAL_II_ANON_NAMESPACE_BOGUS_WARNING
  transform (TRANS::ScalePoint<spacedim>(scaling_factor), triangulation);
#else
  transform (ScalePoint<spacedim>(scaling_factor), triangulation);
#endif  
}


template <int dim, template <int, int> class Container, int spacedim>
unsigned int
GridTools::find_closest_vertex (const Container<dim,spacedim> &container,
                                const Point<spacedim> &p)
{
                                   // first get the underlying
                                   // triangulation from the
                                   // container and determine vertices
                                   // and used vertices
   const Triangulation<dim, spacedim> &tria = get_tria(container);

   const std::vector< Point<spacedim> > &vertices = tria.get_vertices();
   const std::vector< bool       > &used     = tria.get_used_vertices();

                                   // At the beginning, the first
                                   // used vertex is the closest one
   std::vector<bool>::const_iterator first =
      std::find(used.begin(), used.end(), true);

                                   // Assert that at least one vertex
                                   // is actually used
   Assert(first != used.end(), ExcInternalError());
   
   unsigned int best_vertex = std::distance(used.begin(), first);
   double       best_dist   = (p - vertices[best_vertex]).square();

                                   // For all remaining vertices, test
                                   // whether they are any closer
   for(unsigned int j = best_vertex+1; j < vertices.size(); j++)
      if(used[j])
         {
            double dist = (p - vertices[j]).square();
            if(dist < best_dist)
               {
                  best_vertex = j;
                  best_dist   = dist;
               }
         }

   return best_vertex;
}


template<int dim, template<int, int> class Container, int spacedim>
std::vector<typename Container<dim,spacedim>::active_cell_iterator>
GridTools::find_cells_adjacent_to_vertex(const Container<dim,spacedim> &container,
                                         const unsigned int    vertex)
{
                                   // make sure that the given vertex is
                                   // an active vertex of the underlying
                                   // triangulation
   Assert(vertex < get_tria(container).n_vertices(),
          ExcIndexRange(0,get_tria(container).n_vertices(),vertex));
   Assert(get_tria(container).get_used_vertices()[vertex],
          ExcVertexNotUsed(vertex));

				  // We use a set instead of a vector
				  // to ensure that cells are inserted only 
				  // once. A bug in the previous version 
				  // prevented some cases to be 
				  // treated correctly
	     std::set<typename Container<dim,spacedim>::active_cell_iterator> adj_cells_set;
   
   typename Container<dim,spacedim>::active_cell_iterator
      cell = container.begin_active(),
      endc = container.end();
   
                                   // go through all active cells and look
                                   // if the vertex is part of that cell
   for (; cell != endc; ++cell)
      for (unsigned v = 0; v < GeometryInfo<dim>::vertices_per_cell; v++)
         if (cell->vertex_index(v) == vertex)
            {
                                   // OK, we found a cell that contains
                                   // the particular vertex. We add it
                                   // to the list.
               adj_cells_set.insert(cell);

                                   // Now we need to make sure that the
                                   // vertex is not a locally refined
                                   // vertex not being part of the
                                   // neighboring cells. So we loop over
                                   // all faces to which this vertex
                                   // belongs, check the level of
                                   // the neighbor, and if it is coarser,
                                   // then check whether the vertex is
                                   // part of that neighbor or not.
               for (unsigned vface = 0; vface < dim; vface++)
                  {
                     const unsigned face =
                        GeometryInfo<dim>::vertex_to_face[v][vface];
                     if (!cell->at_boundary(face))
		       {
			 typename Container<dim,spacedim>::cell_iterator
                           nb = cell->neighbor(face);
                        
							  // Here we
							  // check
							  // whether
							  // the
							  // neighbor
							  // is
							  // coarser. If
							  // it is, we
							  // search
							  // for the
							  // vertex in
							  // this
							  // coarser
							  // cell and
							  // only if
							  // not found
							  // we will
							  // add the
							  // coarser
							  // cell
							  // itself
                           if (nb->level() < cell->level())
			     {
			       bool found = false;
			       for (unsigned v=0; v<GeometryInfo<dim>::vertices_per_cell; v++)
                                 if (nb->vertex_index(v) == vertex)
				   {
				     found = true;
				     break;
				   }
			       if (!found)
				   adj_cells_set.insert(nb);
			     }
		       }
                  }
               
               break;
            }
   
   std::vector<typename Container<dim,spacedim>::active_cell_iterator> adjacent_cells;

					// We now produce the output vector
					// from the set that we assembled above.
   typename std::set<typename Container<dim,spacedim>::active_cell_iterator>::iterator 
       it = adj_cells_set.begin(), 
       endit = adj_cells_set.end();
   for(; it != endit; ++it) 
       adjacent_cells.push_back(*it);
   
   
   Assert(adjacent_cells.size() > 0, ExcInternalError());
   
   return adjacent_cells;
}  


template <int dim, template<int, int> class Container, int spacedim>
typename Container<dim,spacedim>::active_cell_iterator
GridTools::find_active_cell_around_point (const Container<dim,spacedim>  &container,
                                          const Point<spacedim> &p)
{
   return find_active_cell_around_point(StaticMappingQ1<dim,spacedim>::mapping,
					container, p).first;
}


template <int dim, template <int, int> class Container, int spacedim>
std::pair<typename Container<dim,spacedim>::active_cell_iterator, Point<spacedim> >
GridTools::find_active_cell_around_point (const Mapping<dim,spacedim>   &mapping,
                                          const Container<dim,spacedim> &container,
                                          const Point<spacedim>     &p)
{
   typedef typename Container<dim,spacedim>::active_cell_iterator cell_iterator;

                                   // The best distance is set to the
                                   // maximum allowable distance from
                                   // the unit cell; we assume a
                                   // max. deviation of 1e-10
   double best_distance = 1e-10;
   int    best_level = -1;
   std::pair<cell_iterator, Point<spacedim> > best_cell;

                                   // Find closest vertex and determine
                                   // all adjacent cells
   unsigned int vertex = find_closest_vertex(container, p);
   
   std::vector<cell_iterator> adjacent_cells =
      find_cells_adjacent_to_vertex(container, vertex);

   typename std::vector<cell_iterator>::const_iterator
      cell = adjacent_cells.begin(),
      endc = adjacent_cells.end();

   for(; cell != endc; ++cell)
      {
         const Point<spacedim> p_cell = mapping.transform_real_to_unit_cell(*cell, p);

                                   // calculate the infinity norm of
                                   // the distance vector to the unit cell.
         const double dist = GeometryInfo<dim>::distance_to_unit_cell(p_cell);

                                   // We compare if the point is inside the
                                   // unit cell (or at least not too far
                                   // outside). If it is, it is also checked
                                   // that the cell has a more refined state
         if (dist < best_distance ||
	     (dist == best_distance && (*cell)->level() > best_level))
            {
               best_distance = dist;
               best_level    = (*cell)->level();
               best_cell     = std::make_pair(*cell, p_cell);
            }
      }

   Assert (best_cell.first.state() == IteratorState::valid,
	   ExcPointNotFound<dim>(p));

   return best_cell;
}



template <int dim, int spacedim>
std::pair<typename hp::DoFHandler<dim,spacedim>::active_cell_iterator, Point<spacedim> >
GridTools::find_active_cell_around_point (const hp::MappingCollection<dim,spacedim>   &mapping,
                                          const hp::DoFHandler<dim,spacedim> &container,
                                          const Point<spacedim>     &p)
{
   typedef typename hp::DoFHandler<dim,spacedim>::active_cell_iterator cell_iterator;

                                   // The best distance is set to the
                                   // maximum allowable distance from
                                   // the unit cell; we assume a
                                   // max. deviation of 1e-10
   double best_distance = 1e-10;
   int    best_level = -1;
   std::pair<cell_iterator, Point<spacedim> > best_cell;

                                   // Find closest vertex and determine
                                   // all adjacent cells
   unsigned int vertex = find_closest_vertex(container, p);
   
   std::vector<cell_iterator> adjacent_cells =
      find_cells_adjacent_to_vertex(container, vertex);

   typename std::vector<cell_iterator>::const_iterator
      cell = adjacent_cells.begin(),
      endc = adjacent_cells.end();

   for(; cell != endc; ++cell)
      {
         const Point<spacedim> p_cell
	   = mapping[(*cell)->active_fe_index()].transform_real_to_unit_cell(*cell, p);

                                   // calculate the infinity norm of
                                   // the distance vector to the unit cell.
         const double dist = GeometryInfo<dim>::distance_to_unit_cell(p_cell);

                                   // We compare if the point is inside the
                                   // unit cell (or at least not too far
                                   // outside). If it is, it is also checked
                                   // that the cell has a more refined state
         if (dist < best_distance ||
	     (dist == best_distance && (*cell)->level() > best_level))
            {
               best_distance = dist;
               best_level    = (*cell)->level();
               best_cell     = std::make_pair(*cell, p_cell);
            }
      }

   Assert (best_cell.first.state() == IteratorState::valid,
	   ExcPointNotFound<dim>(p));

   return best_cell;
}



template <int dim, int spacedim>
void
GridTools::
get_face_connectivity_of_cells (const Triangulation<dim,spacedim> &triangulation,
				SparsityPattern          &cell_connectivity)
{
				   // as built in this function, we
				   // only consider face neighbors,
				   // which leads to a fixed number of
				   // entries per row (don't forget
				   // that each cell couples with
				   // itself, and that neighbors can
				   // be refined)
  cell_connectivity.reinit (triangulation.n_active_cells(),
			    triangulation.n_active_cells(),
			    GeometryInfo<dim>::faces_per_cell
			    * GeometryInfo<dim>::max_children_per_face
			    +
			    1);

				   // next we have to build a mapping from the
				   // list of cells to their indices. for
				   // this, use the user_index field
  std::vector<unsigned int> saved_user_indices;
  triangulation.save_user_indices (saved_user_indices);
  unsigned int index = 0;
  for (typename Triangulation<dim,spacedim>::active_cell_iterator
         cell = triangulation.begin_active();
       cell != triangulation.end(); ++cell, ++index)
    cell->set_user_index (index);

				   // next loop over all cells and
				   // their neighbors to build the
				   // sparsity pattern. note that it's
				   // a bit hard to enter all the
				   // connections when a neighbor has
				   // children since we would need to
				   // find out which of its children
				   // is adjacent to the current
				   // cell. this problem can be
				   // omitted if we only do something
				   // if the neighbor has no children
				   // -- in that case it is either on
				   // the same or a coarser level than
				   // we are. in return, we have to
				   // add entries in both directions
				   // for both cells
  index = 0;
  for (typename Triangulation<dim,spacedim>::active_cell_iterator
         cell = triangulation.begin_active();
       cell != triangulation.end(); ++cell, ++index)
    {
      cell_connectivity.add (index, index);
      for (unsigned int f=0; f<GeometryInfo<dim>::faces_per_cell; ++f)
	if ((cell->at_boundary(f) == false)
	    &&
	    (cell->neighbor(f)->has_children() == false))
	  {
	    cell_connectivity.add (index,
				   cell->neighbor(f)->user_index());
	    cell_connectivity.add (cell->neighbor(f)->user_index(),
				   index);
	  }
    }
  
				   // now compress the so-built connectivity
				   // pattern and restore user indices. the
				   // const-cast is necessary since we treat
				   // the triangulation as constant (we here
				   // return it to its original state)
  cell_connectivity.compress ();
  const_cast<Triangulation<dim,spacedim>&>(triangulation)
    .load_user_indices (saved_user_indices);  
}



template <int dim, int spacedim>
void
GridTools::
partition_triangulation (const unsigned int           n_partitions,
                         Triangulation<dim,spacedim> &triangulation)
{
  Assert (n_partitions > 0, ExcInvalidNumberOfPartitions(n_partitions));

                                   // check for an easy return
  if (n_partitions == 1)
    {
      for (typename Triangulation<dim>::active_cell_iterator
             cell = triangulation.begin_active();
           cell != triangulation.end(); ++cell)
        cell->set_subdomain_id (0);
      return;
    }

                                   // we decompose the domain by first
                                   // generating the connection graph of all
                                   // cells with their neighbors, and then
                                   // passing this graph off to METIS.
				   // finally defer to the other function for
				   // partitioning and assigning subdomain ids
  SparsityPattern cell_connectivity;
  get_face_connectivity_of_cells (triangulation, cell_connectivity);
  
  partition_triangulation (n_partitions,
			   cell_connectivity,
			   triangulation);
}



template <int dim, int spacedim>
void
GridTools::
partition_triangulation (const unsigned int           n_partitions,
			 const SparsityPattern        &cell_connection_graph,
                         Triangulation<dim,spacedim>  &triangulation)
{
  Assert (n_partitions > 0, ExcInvalidNumberOfPartitions(n_partitions));
  Assert (cell_connection_graph.n_rows() == triangulation.n_active_cells(),
	  ExcMessage ("Connectivity graph has wrong size"));
  Assert (cell_connection_graph.n_cols() == triangulation.n_active_cells(),
	  ExcMessage ("Connectivity graph has wrong size"));  
  
                                   // check for an easy return
  if (n_partitions == 1)
    {
      for (typename Triangulation<dim>::active_cell_iterator
             cell = triangulation.begin_active();
           cell != triangulation.end(); ++cell)
        cell->set_subdomain_id (0);
      return;
    }

                                   // partition this connection graph and get
                                   // back a vector of indices, one per degree
                                   // of freedom (which is associated with a
                                   // cell)
  std::vector<unsigned int> partition_indices (triangulation.n_active_cells());
  SparsityTools::partition (cell_connection_graph, n_partitions,  partition_indices);

                                   // finally loop over all cells and set the
                                   // subdomain ids
  std::vector<unsigned int> dof_indices(1);
  unsigned int index = 0;
  for (typename Triangulation<dim,spacedim>::active_cell_iterator
         cell = triangulation.begin_active();
       cell != triangulation.end(); ++cell, ++index)
    cell->set_subdomain_id (partition_indices[index]);
}



template <int dim, int spacedim>
void
GridTools::
get_subdomain_association (const Triangulation<dim, spacedim>  &triangulation,
                           std::vector<unsigned int> &subdomain)
{
  Assert (subdomain.size() == triangulation.n_active_cells(),
          ExcDimensionMismatch (subdomain.size(),
                                triangulation.n_active_cells()));
  unsigned int index = 0;
  for (typename Triangulation<dim, spacedim>::active_cell_iterator
         cell = triangulation.begin_active();
       cell!=triangulation.end(); ++cell, ++index)
    subdomain[index] = cell->subdomain_id();

  Assert (index == subdomain.size(), ExcInternalError());
}



template <int dim, int spacedim>
unsigned int
GridTools::
count_cells_with_subdomain_association (const Triangulation<dim, spacedim> &triangulation,
                                        const unsigned int        subdomain)
{
  unsigned int count = 0;
  for (typename Triangulation<dim, spacedim>::active_cell_iterator
         cell = triangulation.begin_active();
       cell!=triangulation.end(); ++cell)
    if (cell->subdomain_id() == subdomain)
      ++count;

  Assert (count != 0, ExcNonExistentSubdomain(subdomain));

  return count;
}



template <typename Container>
std::list<std::pair<typename Container::cell_iterator,
                    typename Container::cell_iterator> >
GridTools::get_finest_common_cells (const Container &mesh_1,
                                    const Container &mesh_2)
{
  Assert (have_same_coarse_mesh (mesh_1, mesh_2),
          ExcMessage ("The two containers must be represent triangulations that "
                      "have the same coarse meshes"));

                                   // the algorithm goes as follows:
                                   // first, we fill a list with pairs
                                   // of iterators common to the two
                                   // meshes on the coarsest
                                   // level. then we traverse the
                                   // list; each time, we find a pair
                                   // of iterators for which both
                                   // correspond to non-active cells,
                                   // we delete this item and push the
                                   // pairs of iterators to their
                                   // children to the back. if these
                                   // again both correspond to
                                   // non-active cells, we will get to
                                   // the later on for further
                                   // consideration
  typedef
    std::list<std::pair<typename Container::cell_iterator,
                        typename Container::cell_iterator> >
    CellList;
  
  CellList cell_list;

                                   // first push the coarse level cells
  typename Container::cell_iterator
    cell_1 = mesh_1.begin(0),
    cell_2 = mesh_2.begin(0);
  for (; cell_1 != mesh_1.end(0); ++cell_1, ++cell_2)
    cell_list.push_back (std::make_pair (cell_1, cell_2));

                                   // then traverse list as described
                                   // above
  typename CellList::iterator cell_pair = cell_list.begin();
  while (cell_pair != cell_list.end())
    {
                                       // if both cells in this pair
                                       // have children, then erase
                                       // this element and push their
                                       // children instead
      if (cell_pair->first->has_children()
          &&
          cell_pair->second->has_children())
        {
	  Assert(cell_pair->first->refinement_case()==
		 cell_pair->second->refinement_case(), ExcNotImplemented());
          for (unsigned int c=0; c<cell_pair->first->n_children(); ++c)
            cell_list.push_back (std::make_pair (cell_pair->first->child(c),
                                                 cell_pair->second->child(c)));

                                           // erasing an iterator
                                           // keeps other iterators
                                           // valid, so already
                                           // advance the present
                                           // iterator by one and then
                                           // delete the element we've
                                           // visited before
          const typename CellList::iterator previous_cell_pair = cell_pair;
          ++cell_pair;

          cell_list.erase (previous_cell_pair);
        }
      else
                                         // both cells are active, do
                                         // nothing
        ++cell_pair;
    }

                                   // just to make sure everything is ok,
                                   // validate that all pairs have at least one
                                   // active iterator or have different
                                   // refinement_cases
  for (cell_pair = cell_list.begin(); cell_pair != cell_list.end(); ++cell_pair)
    Assert (cell_pair->first->active()
            ||
            cell_pair->second->active()
	    ||
	    (cell_pair->first->refinement_case()
	     != cell_pair->second->refinement_case()),
            ExcInternalError());

  return cell_list;
}

template <int dim, int spacedim>
bool
GridTools::have_same_coarse_mesh (const Triangulation<dim, spacedim> &mesh_1,
                                  const Triangulation<dim, spacedim> &mesh_2)
{
                                   // make sure the two meshes have
                                   // the same number of coarse cells
  if (mesh_1.n_cells (0) != mesh_2.n_cells (0))
    return false;

                                   // if so, also make sure they have
                                   // the same vertices on the cells
                                   // of the coarse mesh
  typename Triangulation<dim, spacedim>::cell_iterator
    cell_1 = mesh_1.begin(0),
    cell_2 = mesh_2.begin(0),
    endc   = mesh_1.end(0);
  for (; cell_1!=endc; ++cell_1, ++cell_2)
    for (unsigned int v=0; v<GeometryInfo<dim>::vertices_per_cell; ++v)
      if (cell_1->vertex(v) != cell_2->vertex(v))
        return false;

                                   // if we've gotten through all
                                   // this, then the meshes really
                                   // seem to have a common coarse
                                   // mesh
  return true;
}



template <typename Container>
bool
GridTools::have_same_coarse_mesh (const Container &mesh_1,
                                  const Container &mesh_2)
{
  return have_same_coarse_mesh (mesh_1.get_tria(),
                                mesh_2.get_tria());
}



template <int dim, int spacedim>
double
GridTools::minimal_cell_diameter (const Triangulation<dim, spacedim> &triangulation)
{
  double min_diameter = triangulation.begin_active()->diameter();
  for (typename Triangulation<dim, spacedim>::active_cell_iterator
	 cell = triangulation.begin_active(); cell != triangulation.end();
       ++cell)
    min_diameter = std::min (min_diameter,
			     cell->diameter());
  return min_diameter;
}



template <int dim, int spacedim>
double
GridTools::maximal_cell_diameter (const Triangulation<dim, spacedim> &triangulation)
{
  double max_diameter = triangulation.begin_active()->diameter();
  for (typename Triangulation<dim, spacedim>::active_cell_iterator
	 cell = triangulation.begin_active(); cell != triangulation.end();
       ++cell)
    max_diameter = std::max (max_diameter,
			     cell->diameter());
  return max_diameter;
}



template <int dim, int spacedim>
void
GridTools::create_union_triangulation (const Triangulation<dim, spacedim> &triangulation_1,
				       const Triangulation<dim, spacedim> &triangulation_2,
				       Triangulation<dim, spacedim>       &result)
{
  Assert (have_same_coarse_mesh (triangulation_1, triangulation_2),
	  ExcMessage ("The two input triangulations are not derived from "
		      "the same coarse mesh as required."));

				   // first copy triangulation_1, and
				   // then do as many iterations as
				   // there are levels in
				   // triangulation_2 to refine
				   // additional cells. since this is
				   // the maximum number of
				   // refinements to get from the
				   // coarse grid to triangulation_2,
				   // it is clear that this is also
				   // the maximum number of
				   // refinements to get from any cell
				   // on triangulation_1 to
				   // triangulation_2
  result.clear ();
  result.copy_triangulation (triangulation_1);
  for (unsigned int iteration=0; iteration<triangulation_2.n_levels();
       ++iteration)
    {
      InterGridMap<Triangulation<dim, spacedim> > intergrid_map;
      intergrid_map.make_mapping (result, triangulation_2);

      bool any_cell_flagged = false;
      for (typename Triangulation<dim, spacedim>::active_cell_iterator
	     result_cell = result.begin_active();
	   result_cell != result.end(); ++result_cell)
	if (intergrid_map[result_cell]->has_children())
	  {
	    any_cell_flagged = true;
	    result_cell->set_refine_flag ();
	  }

      if (any_cell_flagged == false)
	break;
      else
	result.execute_coarsening_and_refinement();
    }
}




// explicit instantiations

#if deal_II_dimension != 1
template
double
GridTools::diameter<deal_II_dimension> (const Triangulation<deal_II_dimension> &);
#endif

#if deal_II_dimension == 2
template
double
GridTools::diameter<deal_II_dimension, deal_II_dimension+1> (const Triangulation<deal_II_dimension, deal_II_dimension+1> &);
#endif

template
void GridTools::delete_unused_vertices (std::vector<Point<deal_II_dimension> > &,
					std::vector<CellData<deal_II_dimension> > &,
					SubCellData &);

template
void GridTools::delete_duplicated_vertices (std::vector<Point<deal_II_dimension> > &,
					    std::vector<CellData<deal_II_dimension> > &,
					    SubCellData &,
					    std::vector<unsigned int> &,
					    double);

template
void GridTools::shift<deal_II_dimension> (const Point<deal_II_dimension> &,
					  Triangulation<deal_II_dimension> &);

template
void GridTools::scale<deal_II_dimension> (const double,
					  Triangulation<deal_II_dimension> &);

template
std::pair<hp::DoFHandler<deal_II_dimension>::active_cell_iterator, Point<deal_II_dimension> >
GridTools::find_active_cell_around_point (const hp::MappingCollection<deal_II_dimension> &,
                                          const hp::DoFHandler<deal_II_dimension> &,
                                          const Point<deal_II_dimension> &);

template
void
GridTools::
get_face_connectivity_of_cells (const Triangulation<deal_II_dimension> &triangulation,
				SparsityPattern          &cell_connectivity);

template
void
GridTools::partition_triangulation (const unsigned int,
                                    Triangulation<deal_II_dimension> &);

template
void
GridTools::partition_triangulation (const unsigned int,
				    const SparsityPattern &,
                                    Triangulation<deal_II_dimension> &);

template
void
GridTools::
get_subdomain_association (const Triangulation<deal_II_dimension>  &,
                           std::vector<unsigned int> &);

template
unsigned int
GridTools::
count_cells_with_subdomain_association (const Triangulation<deal_II_dimension> &,
                                        const unsigned int        );


template
double
GridTools::minimal_cell_diameter (const Triangulation<deal_II_dimension> &triangulation);

template
double
GridTools::maximal_cell_diameter (const Triangulation<deal_II_dimension> &triangulation);

template
void
GridTools::create_union_triangulation (const Triangulation<deal_II_dimension> &triangulation_1,
				       const Triangulation<deal_II_dimension> &triangulation_2,
				       Triangulation<deal_II_dimension>       &result);


#if deal_II_dimension != 3

template
void GridTools::delete_unused_vertices (std::vector<Point<deal_II_dimension+1> > &,
					std::vector<CellData<deal_II_dimension> > &,
					SubCellData &);

template
void GridTools::delete_duplicated_vertices (std::vector<Point<deal_II_dimension+1> > &,
					    std::vector<CellData<deal_II_dimension> > &,
					    SubCellData &,
					    std::vector<unsigned int> &,
					    double);

template
void GridTools::shift<deal_II_dimension, deal_II_dimension+1> (const Point<deal_II_dimension+1> &,
					  Triangulation<deal_II_dimension, deal_II_dimension+1> &);

template
void GridTools::scale<deal_II_dimension, deal_II_dimension+1> (const double,
					  Triangulation<deal_II_dimension, deal_II_dimension+1> &);



#endif


#include "../grid/grid_tools.inst"

#if deal_II_dimension < 3

template
    std::list<std::pair<Triangulation<deal_II_dimension,deal_II_dimension+1>::cell_iterator, Triangulation<deal_II_dimension,deal_II_dimension+1>::cell_iterator> >
    GridTools::
    get_finest_common_cells (const Triangulation<deal_II_dimension,deal_II_dimension+1> &mesh_1,
			     const Triangulation<deal_II_dimension,deal_II_dimension+1> &mesh_2);

template
    std::list<std::pair<DoFHandler<deal_II_dimension,deal_II_dimension+1>::cell_iterator, DoFHandler<deal_II_dimension,deal_II_dimension+1>::cell_iterator> >
    GridTools::
    get_finest_common_cells (const DoFHandler<deal_II_dimension,deal_II_dimension+1> &mesh_1,
			     const DoFHandler<deal_II_dimension,deal_II_dimension+1> &mesh_2);

template
    std::list<std::pair<hp::DoFHandler<deal_II_dimension,deal_II_dimension+1>::cell_iterator, hp::DoFHandler<deal_II_dimension,deal_II_dimension+1>::cell_iterator> >
    GridTools::
    get_finest_common_cells (const hp::DoFHandler<deal_II_dimension,deal_II_dimension+1> &mesh_1,
			     const hp::DoFHandler<deal_II_dimension,deal_II_dimension+1> &mesh_2);

#endif

DEAL_II_NAMESPACE_CLOSE

