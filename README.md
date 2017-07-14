
Esta calculador procesa expresiones matematicas en una cadena.
Primero hice el algoritmo en c++ y luego lo traduci al asembler

Las expresiones matematicas pueden tener:
    - parentesis (, )
    - suma: +
    - resta: -
    - multiplicion: *
    - division: /
    - potenciacion: ^

Limitaciones:
    - Se asume que la expresion es correcta y no tiene espacios
    - La division es entera, no se como usar puntos flotantes
    - un operador siempre debe estar entre dos numero. por ejemplo '-5' no se procesaria bien.
    - los numeros son de 16 bits con signo, por lo que el rango de valores
        que puede procesar es de [-32768, 32767]. Si el resultado se sale de esos limites
        no se puede asegurar respuesta correcta
    - va procesando caracter por caracter hasta que encuentra enter, por lo que el borrado
        de algun caracter no es posible

ejemplos de expresiones:
1+2*3
5+2^5-40
2+20/10
20^3
2*(1+2*3-10)