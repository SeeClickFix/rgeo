# -----------------------------------------------------------------------------
# 
# Access to geographic data factories
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo
  
  module Geography
    
    @simple_spherical = nil
    @simple_mercator = nil
    
    class << self
      
      
      # Geographic features provided by this factory perform calculations
      # assuming a spherical earth. In other words, geodesics are treated
      # as great circle arcs, and size and geometric calculations are
      # treated accordingly. Distance and area calculations report results
      # in meters. This makes this implementation ideal for everyday
      # calculations on the globe where accuracy within about 0.5 percent
      # is sufficient.
      # 
      # Currently, this implementation is incomplete. Basic input/output
      # and a few geodesic functions are implemented, but many return nil.
      # 
      # Simple_spherical features report SRID=4326, indicating EPSG 4326
      # (i.e. the WGS84 spheroid and the lat/lon system commonly used by
      # most GIS systems).
      # This is technically not correct, for two reasons:
      # 
      # * We are running calculations on a spherical approximation of the
      #   WGS84 spheroid rather than the ellipsoidal shape itself.
      # * While most functions use the EPSG 4326 unit of degrees longitude
      #   and latitude, a few (specifically, distance and area calculations)
      #   return their results in meters.
      # 
      # We, however, hereby punt on this issue for this particular factory,
      # on the theory that, for "most applications" that we expect will
      # want to use this library, these behaviors are sufficient, and the
      # SRID imprecision isn't crucial.
      # Note, however, that this means features created with this factory
      # may generate slightly different results from geodesic calculations 
      # than those generated by, e.g., PostGIS (unless you direct PostGIS
      # to use spherical geodesics).
      
      def simple_spherical(opts_={})  # :nodoc:
        @simple_spherical ||= Geography::Factory.new(Geography::SimpleSpherical)
      end
      
      
      # Geographic features provided by this factory perform calculations
      # on the simple mercator projection currently used by Google and
      # Bing maps. This makes this implementation ideal for representing
      # and performing calculations on features to be visualized using
      # those technologies. Note, however, that significant discrepancies
      # may occur for large features between the "mapping visualization"
      # sizes and shapes, and the actual sizes and shapes on the globe,
      # because the mercator projection, like all projections of a
      # non-flat earth onto a flat coordinate system, does introduce
      # distortions (especially near the poles.)
      # 
      # Distance and area computations return results in meters, whereas
      # all coordinates are represented in degrees latitude and longitude.
      # 
      # This is not a true projected spatial reference: point coordinates
      # are still represented in degrees latitude and longitude. However,
      # computations are done in the projected spatial reference. (That
      # spatial reference is EPSG 3857, for the interested.) This means,
      # for example, that a line segment whose endpoints fall on a line of
      # latitude away from the equator will follow the line of latitude
      # rather than the actual geodesic (which will curve away from the
      # equator in the projected coordinate system). It also means that
      # latitudes very near the poles are excluded. Specifically,
      # latitudes are restricted to the range (-85.05112877980659,
      # 85.05112877980659), which conveniently results in a square
      # projected domain.
      # 
      # In general, this implementation is designed specifically for
      # mapping applications using Google and Bing maps, and any others
      # that use the same projection.
      # 
      # Simple_mercator features report SRID=4326, indicating EPSG 4326
      # (i.e. the WGS84 spheroid and the lat/lon system commonly used by
      # most GIS systems).
      # This is actualy grossly inaccurate for a number of reasons, chief
      # among them being that calculations are being done on a projection,
      # whereas EPSG 4326 calculations are supposed to be done on the
      # spheroid. However, we continue to report SRID=4326 because the x
      # and y coordinates represent latitude and longitude rather than
      # projected coordinates. There is no EPSG spatial reference that
      # describes the <i>actual</i> behavior of the common map
      # visualization APIs, so we've decided to fudge on this in the
      # interest of being true to our expected application use cases.
      
      def simple_mercator(opts_={})
        @simple_mercator ||= Geography::Factory.new(Geography::SimpleMercator, :buffer_resolution => opts_[:buffer_resolution])
      end
      
      
    end
    
  end
  
end
