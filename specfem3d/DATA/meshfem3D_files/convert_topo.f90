program convert_topo

integer :: ix,iy,nx,ny
real :: lon,lat
real, dimension(:,:), allocatable :: itopo_bathy

nx=1401
ny=1001
allocate(itopo_bathy(nx,ny))
open(12,file='topo_bathy_final.dat',status='old',action='read')
open(13,file='topo.geo',status='unknown')
do iy=1,ny
  do ix=1,nx
    lon=-121.+(ix-1)*0.005
    lat=32.+(iy-1)*0.005
    read(12,*)itopo_bathy(ix,iy)
    write(13,*) lon,lat,itopo_bathy(ix,iy)
  enddo
enddo
close(12)
close(13)
deallocate(itopo_bathy)
end program convert_topo
