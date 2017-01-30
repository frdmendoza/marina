function [salida,ok]=cadena_caracteres_num(entrada,longitud)
%
% A partir de un n�mero, genera una cadena de caracteres de longitud fija
% - si el num de entrada es m�s largo:
%       salida: ceros
%       ok    : 0 (false)
% - si el num de entrada es m�s corto:
%       rellena con ceros a la izquierda
%       ok    : 1 (true)
% (L. Ram�rez, abril 2013)
%
% [salida,ok]=cadena_caracteres_num[entrada,longitud]
% 
% entrada  : num de entrada
% longitud : longitud de la cadena de salida

numero=num2str(entrada);

if numel(numero)<=longitud 
    relleno(1:(longitud-numel(numero)))='0';
    cadena=[relleno numero];
    ok=1;
else
    cadena(1:longitud)='0';
    ok=0;
end
salida=cadena;