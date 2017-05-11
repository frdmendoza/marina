function [result,usados,cambiados,contador,control]...
    = subs_days_dw(month,days_m,RMV,limit,max_dist,max_times,max_subs)
%SUBS_DAYS_DW Carry out days substitutions to decrement the monthly value
%towards the Representative monthly value (RMV).
%   INPUT:
%   month: Number of the evaluated month.
%   days_m: Number of the day and daily irradiance in kWh/m2.
%   RMV: Representative long term monthly value (objective value).
%   max_dist: Maximum distance in the days used for the substitution
%   (+-max_dist).
%   max_times: Maximum number of times that the same day may appear in the
%   generated data set.
%   max_subs: Maximum number of substitutions allowed each month.
%
%   OUTPUT:
%   result: aaa
%
% - F. Mendoza (May 2017) Update

num_dias_mes=[31 28 31 30 31 30 31 31 30 31 30 31];
%Inicializamos los vectores:
% cambiados: es un vector l�gico de 1 dimensi�n [1 a num_dias(mes)]:
%               toma valor 1: si el d�a ya ha sido cambiado
%               toma valor 0: si el d�a NO ha sido cambiado
Dias_input=days_m(:,1);
Dias_ord=1:num_dias_mes(month);
cambiados=Dias_input~=Dias_ord';

% usados: es un vector l�gico de 2 dimensiones:
%       filas: [1 a num_dias(mes)]:
%       columnas: una columna por cambio realizado:
%               toma valor 1: la fila del d�a usado
%               toma valor 0: si el d�a NO ha sido usado
pos_cambiados=find(cambiados); % posiciones de los cambiados
valores_usados=Dias_input(pos_cambiados);
usados(1:num_dias_mes(month),1)=0;

for i=1:numel(valores_usados)
    usados(valores_usados(i),i)=1;
end

% realiza los cambios en los valores diarios necesarios para
% acercarse al valor objetivo por la iquierda
SUMA=sum(days_m(:,2));

control=SUMA-RMV; % Diferencia entre el valor mensual de la campa�a de medidas y el Valor mensual representativo
% Para este caso siempre es positivo
contador=0;

result(:,1)=days_m(:,1); % posiciones iniciales
result(:,2)=days_m(:,2); % valores iniciales

if control > limit  % Condicion de estar por fuera del limte establecido
    while (control > limit && contador<=max_subs)
        
        contador=contador+1;
        
        col_pos_ini=(contador*2)-1;
        col_val_ini=contador*2;
        
        [maximo,posicionmax]=max((result(:,col_val_ini).*~cambiados));  % Valor maximo de radiaci�n y su posicion
        pos_prim=posicionmax(1)-max_dist;
        pos_ultm=posicionmax(1)+max_dist;
        if pos_prim<=0     %asumimos que el vector de entrada solo tiene el num de dias del mes
            pos_prim=1;
        end
        if pos_ultm>=num_dias_mes(month)
            pos_ultm=num_dias_mes(month);
        end
        posiciones=(pos_prim:1:pos_ultm); %vector con el trocito de las posiciones posibles
        posiciones_logicas(1:num_dias_mes(month),1)=0; %inicilizamos vector l�gico de todo el mes a ceros
        posiciones_logicas(posiciones,1)=1; %vector l�gico con 1 en las posibles de cambio posibles
        
        poco_usados=(sum(usados,2)<max_times); %Suma de los valores logicos de la fila que no pueden ser mas de 4
        
        %sentencia del mill�n!!
        % Vector l�gico que tiene en cuenta:
        % a: que est�n entre los +-n d�as permitidos
        % b: que no haya sido cambiado anterioremente el d�a
        % c: que no se haya usado ya el m�ximo de veces
        posibles=posiciones_logicas.*~cambiados.*poco_usados;
        
        if sum(posibles)==0
            fprintf('Not possible possitions mes:%d. Contador: %d \n',month, contador);
            break
        end
        
        valores_posibles=result(:,col_val_ini);   % A(posiciones,2);
        incremento=(valores_posibles-result(posicionmax,col_val_ini));
        falta= (abs(incremento+control)).*posibles;   % el control es negativo, si posibles=0 ese valor no se tiene en ciuenta
        % y entonces aqui solo quedan los dias cercanos
        optimo=min(falta(falta~=0));     % se elige el valor por el cual reemplazar el minimo que se aproxima mas a cero
        TEMP=find(falta==optimo);
        pos_optimo=TEMP(1);    % Encuentra la posicion del valor a reemplazar en el vector falta
        
        col_pos_fin=contador*2+1;
        col_val_fin=contador*2+2;
        
        % inicilizaci�n de las dos columnas de salida,
        % con los valores de entrada
        result(:,col_pos_fin)=result(:,col_pos_ini); % posiciones iniciales
        result(:,col_val_fin)=result(:,col_val_ini); % valores iniciales
        
        %sustituimos el dato de la posici�n cambiada, en la colimna de las
        %posiciones de salida
        result(posicionmax,col_pos_fin)=...
            result(pos_optimo,col_pos_ini); % posici�n sustituida
        %sustituimos el dato del valor cambiado, en la colimna de las
        %posiciones de salida
        result(posicionmax,col_val_fin)=...
            result(pos_optimo,col_val_ini); % valor sustituido
        
        SUMA=sum(result(:,col_val_fin));
        control=(SUMA-RMV);
        
        cambiados(posicionmax,1)=1;
        
        usados(:,contador)=0;
        usados(pos_optimo,contador)=1;
        
    end
    
end

end
