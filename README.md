# Soneta Kubernetes Helm Charts

Funkcjonalność zawarta w tym repozytorium jest w fazie ***beta*** i może być przedmiotem zmian. Funkcjonalność ***beta*** nie podlega gwarancji.

## Użycie

W celu użycia 'paczek', [Helm](https://helm.sh) musi być prawidłowo zainstalowany.
Instalację należy dokonać zgodnie z [dokumentacją](https://helm.sh/docs/).

Po instalacji należy dodać repozytorium przy pomocy poniższego polecenia:
```console
helm repo add soneta https://soneta.github.io/helm-charts
```

W celu przeglądnia zawartości repozytorium należy wykonać polecenie:
```console
helm search repo soneta
```

## Zawartość
[soneta](https://github.com/soneta/helm-charts/blob/main/charts/soneta/README.md) - zestaw umożliwia instalowanie oprogramowania [Soneta](https://enova.pl) w klastrze Kubernetes
