# uutiset

Staattinen etusivu näyttää Ylen uusimmat ammattikorkeakouluja koskevat uutiset.
Ensimmäisenä sisältönä on linkki AMK:n voimassa olevaan työehtosopimukseen ja sen QR-koodi.

## Käyttöönotto

Sivu hakee enintään viisi uutista automaattisesti `fetch`-kutsulla Ylen REST-rajapinnasta ja avaa jokaisen jutun Ylen sivulle. Onnistunut haku säilytetään selaimen istunnon välimuistissa viiden minuutin ajan API-kuorman rajoittamiseksi. Julkaise muutokset komennolla:

```sh
./deploy.sh
```
