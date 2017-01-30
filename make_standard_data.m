function [nombre_salida,datos_salida]=make_standard_data...
    (filedata,timedata, nodata, geodata,fechas,GHI,DNI,DHI,OTRAS)
%
% Versi�n inicial:  L. Ram�rez (abril 2013)
% Modificic�n:      L. ram�rez (julio 2014)
% Modificic�n:      L. ram�rez (May 2015)
%
% Formato del nombre de fichero salida:
% LOCAL-OWN-NN-aaaa
% LOCAL: 5 d�gitos de la localidad 
% OWN  : 3 d�gitos del propietario
% NN   : 2 digitos del numero de estaci�n (de igual localidad y propietario)
% aaa  : 4 caracteres de identificador del a�o del fichero, 
%
% FUNCTIONS:    [salida]=cadena_caracteres(entrada,longitud,char_rell);
%               [salida,ok]=cadena_caracteres_num(entrada,longitud);
%
% ENTRADAS:
% filedata: datos para la creaci�n del nombre de fichero de salida
%   filedata.loc: localidad 
%   filedata.own: propietario
%   filedata.num: numero de estaci�n (de igual localidad y propietario)
%   filedata.ID : identificador del fichero
%   filedata.name: nombre identificador de los datos
% geodata: datos geogr�ficos de la ubicaci�n
%   geodata.lat: latitud [�N] 
%   geodata.lon: longitud [�E]
%   geodata.alt: altitud [m]
% timedata: datos asociados a la referencia horaria de los datos
%   timedata.timezone: zona horaria ('UTC+','VALOR') 
%   timedata.num_obs: numero de observaciones pro hora
%   timedata.etiqueta: instante de la etiqueta de los datos
%                      0 al principio, 0.5 si al medio, 1 si al final
% nodata:
%   nodata: nodata value
% fechas: vector de fechas de los datos
%   ha de corresponder con los vectores de los datos de entrada
%   la frecuencia temporal es indistinta
%   [aaaa mm dd hh mm] en caso de datos minutales
% GHI,DNI,DHI,OTRAS
%   vectores de igual longitud, y con informaci�n de los datos
%   correspondientes.
%   OTRAS: matriz con otras variables adicionales
%
% SALIDA: estructura datos:
%-------------------------------------------
% datos.filedata.own: propietario
% datos.filedata.num: numero de estaci�n (de igual localidad y propietario)
% datos.filedata.loc: localidad 
% datos.filedata.ID : identificador del fichero
% datos.filedata.name: nombre identificador de los datos
%
% datos.geodata.lat => latitud [�N]
% datos.geodata.lon => longitud[�E]
% datos.geodata.alt => altitud [m]
%
% datos.timedata.timezone   => zona horaria
% datos.timedata.etiq       => 0 ppio int; 0.5 centro int; 1 fin del int.
% datos.timedata.num_obs    => num de observaciones por hora
% 
% datos.nodata  => -999
%
% datos.mat => matriz:AAAA MM DD HH mm GHI DNI DHI [otras]
%------------------------------------------------------
% s�lamente lee y escribe, ni ordena ni cambia nada

filedata.loc  = cadena_caracteres(filedata.loc,5,'0');      %FUNCTION
filedata.own  = cadena_caracteres(filedata.own,3,'0');
[filedata.num,ok] = cadena_caracteres_num(filedata.num,2);  %FUNCTION
filedata.ID   = cadena_caracteres(filedata.ID,4,'0');
filedata.name = [filedata.loc '-' filedata.own '-' filedata.num '-' filedata.ID];

datos.filedata = filedata;
datos.geodata  = geodata;
datos.timedata = timedata;
datos.nodata   = nodata;

datos.mat = double([fechas GHI DNI DHI OTRAS]);

hay    = ~isnan(datos.mat(:,1));
datos2 = datos;
datos2.mat = [];
datos2.mat = datos.mat(hay,:);

nombre_salida = filedata.name;
datos_salida  = datos2;


