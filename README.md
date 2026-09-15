# uutiset

Staattinen etusivu näyttää Ylen uusimmat ammattikorkeakouluja koskevat uutiset.
Ensimmäisenä sisältönä on linkki AMK:n voimassa olevaan työehtosopimukseen ja sen QR-koodi.

## Käyttöönotto

Sivu hakee enintään 10 AMK-aiheista uutisriviä automaattisesti `fetch`-kutsuilla Ylen avoimesta Teletext REST -rajapinnasta ja avaa jokaisen rivin Ylen Teksti-TV:ssä. Suodatus tunnistaa AMK-koulujen nimien lisäksi sanat `Sivista` ja `OAJ` kaikista Teletextin tekstilohkoista. Onnistunut haku säilytetään selaimen istunnon välimuistissa viiden minuutin ajan API-kuorman rajoittamiseksi. Ylen julkisessa API:ssa ei tällä hetkellä ole artikkeli- tai AMK-hakua. Julkaise muutokset komennolla:

```sh
./deploy.sh
```
