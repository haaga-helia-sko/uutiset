# uutiset

Staattinen etusivu näyttää Ylen uusimmat ammattikorkeakouluja koskevat uutiset.
Ensimmäisenä sisältönä on linkki AMK:n voimassa olevaan työehtosopimukseen ja sen QR-koodi.

## Käyttöönotto

Sivu hakee uutiset automaattisesti `fetch`-kutsulla Ylen REST-rajapinnasta, näyttää kymmenen uutista sivua kohden ja avaa jokaisen jutun Ylen sivulle. Julkaise muutokset komennolla:

```sh
./deploy.sh
```
