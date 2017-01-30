function datosc = validation(datosc,level)
% FUNCI�N PARA LA VALIDACI�N DE DATOS 
%
% ENTRADA: datos en formato de salida del control de calidad
% --------------------------------------------------------------------
% datos.* a�adiendo las matrices .matc y .astro:
% datos.matc  = [AAAA MM DD HH MM SS GHIord eGHI DNIord eDNI DHIord eDHI];
% datos.astro = [dj e0 ang_dia et tsv_horas w dec cosz i0 m];
%
% siendo eGHI la etiqueta del control de calidad de la variable GHI en
% funcion de los procedimientos BSRN:
%   0 no supera el nivel 1,    valor no f�sicamente posible
%   1 no supera el nivel 2,    valor extremadaemente raro
%   2 no supera el nivel 3,    las tres componentes no son coherentes o no
%                              se puede comprobar
%   3 valor coherente con las tres variables registradas
%
% SALIDA: FICHERO matlab con los datos validados
%  
%  Sheet validaci�n diaria: una hoja con 6 columnas por a�o de datos:
%      Los a�os son de 365 d�as.
%      Col1: d�a juliano;	
%      Col2: valor diario de radiaci�n global  
%      Col3: validez del d�a de global(1/0)
%      Col4: d�a juliano;	
%      Col5: valor diario de DNI 
%      Col6: validez del d�a de DNI(1/0)
%  Sheet validaci�n mensual: una hoja con 6 columnas por a�o de datos:
%      Los a�os son de 12 meses.
%      Col1: mes;	
%      Col2: valor mensual de radiaci�n global (1 v�lido / 0 no v�lido) 
%      Col3: validez del mes en global(1 v�lido / 0 no v�lido) 
%      Col4: mes;	
%      Col5: valor diario de DNI  (impl�citamente 2 si v�lida/0)
%      Col6: validez del d�a en global(1 v�lido / 0 no v�lido) 
%
%------------------------------------------------------------------
lat = datosc.geodata.lat;
num_obs = datosc.timedata.num_obs;
%Nombre del fichero de salida

lat_rad=lat*pi/180;

% damos forma e inicializamos la salida de datos diarios validados
% [dia GHI DNI val_dia] = 4 columnas cada a�o
res_diaria(1:365,6) = NaN;

%------------------------------------------------------------
%lee el valor del a�o de la hoja de datos con calidad
anno=datosc.matc(1,1);

% VALIDACI�N DIARIA-------------------------------
num_dias = 365;        leap = 0;
if mod(anno,4) == 0;   leap = 1; end

for dj=1:365%num_dias
    if (leap == true) && (dj>60)
        num_dia=dj+1;
    else
        num_dia=dj;
    end
    %identificaci�n de las l�neas del d�a en los 8760*num_obs registros del a�o
    lin_ini = ((num_dia-1)*24*num_obs)+1; % si dj=2 => lin_ini=25
    lin_fin = lin_ini+(24*num_obs)-1;  % si dj=2 => lin_fin=48
    %generamos una nueva variable "dia" del dia del mes que vamos a
    %tratar
    dia = datosc.matc(lin_ini,3);

    %extracci�n de los valores diarios
    hora = datosc.matc(lin_ini:lin_fin,4);
    min  = datosc.matc(lin_ini:lin_fin,5);
    GHI  = datosc.matc(lin_ini:lin_fin,7);
    eGHI = datosc.matc(lin_ini:lin_fin,8);
    DNI  = datosc.matc(lin_ini:lin_fin,9);
    eDNI = datosc.matc(lin_ini:lin_fin,10);

    % extraccion de los valores astron�micos de esas horas
    w   = datosc.astro(lin_ini:lin_fin,6);%vector de  posiciones diatintas
    dec = datosc.astro(lin_ini,7); %declinaci�n del primer momento del d�a
    ws  = acos(-tan(dec)*tan(lat_rad));%escalar
    wp  = -ws; %escalar
    i0  = datosc.astro(lin_ini:lin_fin,9); %vector de 24 posiciones diatintas

    % durante el d�a los �ngulos horarios han de ser menores que el de
    % salida (que es positivo) y mayores que le de puesta (negativo)
    pos_dia = (w<ws & w>wp); %con el sol por encima del horizonte

    %llamamos a la funci�n valida_dias con los datos de cada variable
    [serieG,etihG,diariaG,etidG] = ...
        valida_dias(pos_dia,GHI,eGHI,num_obs,level,dj);
    [serieB,etihB,diariaB,etidB] = ...
        valida_dias(pos_dia,DNI,eDNI,num_obs,level,dj);

    %actualiza los datos por si se ha interpolado
    datosc.matc(lin_ini:lin_fin,7) = serieG;
    datosc.matc(lin_ini:lin_fin,8) = etihG;
    datosc.matc(lin_ini:lin_fin,9) = serieB;
    datosc.matc(lin_ini:lin_fin,10)= etihB;

    % Almacena los resultados en una tabla de resultados diarios 
    %   - columnas: 6 : [dj GHI val_GHI dj DNI val_DNI]
    res_diaria(dj,1)=dia;     
    res_diaria(dj,2)=diariaG;   
    res_diaria(dj,3)=etidG; 
    res_diaria(dj,4)=dia;     
    res_diaria(dj,5)=diariaB;  
    res_diaria(dj,6)=etidB;  

end

% VALIDACI�N MENSUAL ------------------------
% Se parte de los resultados de la validaci�n diaria para cada a�o
% LA VALIDACI�N MENSUAL NO SE PUEDE HACER EN DOS VARIABLES
% En el proceso de sustituyen d�as, por Lo que solo puede mandar una: la
% global o la directa, pero la salida es de las dos.
% Dado que tanto el 5.1 como el 5.2 son pasos en
% los que se exige la DNI, va a ser la que dirija el proceso.

% Validaci�n mensual: entra la salida de la validaci�n diaria
% 4 = huecos diarios m�ximos permitidos cada mes.
[diarios,mensuales,cambios,cambios_mes]=valida_meses(res_diaria,4);
%Actualiza los resultados de los cambios de d�as si necesario 
% en la matriz diaria

datosc.diarios     = diarios;
datosc.mensuales   = mensuales;
datosc.cambios     = cambios;
datosc.cambios_mes = cambios_mes;
