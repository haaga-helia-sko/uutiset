# uutiset

Staattinen etusivu näyttää Ylen uusimmat ammattikorkeakouluja koskevat uutiset.
Ensimmäisenä sisältönä on linkki AMK:n voimassa olevaan työehtosopimukseen ja sen QR-koodi.

## Käyttöönotto

Deploy hakee Ylen Ammattikorkeakoulut-aihesivulta 10 uusinta artikkelia palvelinpuolella ja kirjoittaa ne paikalliseen `news.json`-tiedostoon. Etusivu hakee saman originin JSON-tiedoston, joten selain ei törmää Ylen sivun CORS-rajoitukseen. Uutislinkit avautuvat suoraan Ylen artikkeleihin. Julkaise ja päivitä uutiset komennolla:

```sh
./deploy.sh
```
