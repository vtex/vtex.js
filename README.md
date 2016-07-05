# vtex.js

Biblioteca JavaScript para acessar APIs da VTEX

[Guias, exemplos e documentação completa de todos os métodos do vtex.js.](/docs)

Atenção: o vtex.js e sua documentação estão em constante melhorias.

Veja também os [slides da apresentação](http://goo.gl/tYT23t)
sobre o vtex.js que rolou no VTEX Day 2014.

## Desenvolvimento

Para desenvolver rodando os testes, instale as dependências e use o script test-watch:

    npm i
    npm run-script test-watch

## CHANGELOG

### v2.0.0

- Introdução dos eventos `checkoutRequestBegin.vtex` e `checkoutRequestEnd.vtex`
- Evento `orderFormUpdated.vtex` só é emitido quando todos os requests pendentes são resolvidos.
- Ao enviar mais de um request para a mesma operação, todos os anteriores que não foram resolvidos serão abortados. Dessa forma, apenas o último request vai valer.

------

VTEX - 2014
