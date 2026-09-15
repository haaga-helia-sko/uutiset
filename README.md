# uutiset

Staattinen etusivu näyttää Ylen uusimmat ammattikorkeakouluja koskevat uutiset.
Ensimmäisenä sisältönä on linkki AMK:n voimassa olevaan työehtosopimukseen ja sen QR-koodi.

## Käyttöönotto

Sivu hakee enintään 10 AMK-aiheista uutisotsikkoa automaattisesti `fetch`-kutsuilla Ylen avoimesta Teletext REST -rajapinnasta ja avaa jokaisen otsikon Ylen Teksti-TV:ssä. Onnistunut haku säilytetään selaimen istunnon välimuistissa viiden minuutin ajan API-kuorman rajoittamiseksi. Ylen julkisessa API:ssa ei tällä hetkellä ole artikkeli- tai AMK-hakua, joten suodatus tehdään Teletext-otsikoista. Julkaise muutokset komennolla:

```sh
./deploy.sh
```
