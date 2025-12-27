cd ..

for /r "assets" %%v in (*.svg) do dart run vector_graphics_compiler -i  %%v -o %%v.vec

pause