# Soneta Kubernetes Helm Chart

Funkcjonalność zawarta w tym repozytorium jest w fazie ***beta*** i może być przedmiotem zmian. Funkcjonalność ***beta*** nie podlega gwarancji.

## Użycie
Instalacja aplikacji z minimalną parametryzacją (zostaną zastosowane domyślne parametry):
- **sample** to nazwa release'a (dowolna nazwa identyfikująca instancję aplikacji)
- **soneta/soneta** to odpowiednio *repozytorium/nazwa chartu*
- dodatkowo należy wskazać zawartość listy baz danych, z którymi będzie współpracować dana instancja aplikacji.


```console
helm upgrade sample soneta/soneta -f values.yaml --install
```

gdzie zawartość pliku values.yaml to np.:
```yaml
dblist: |-
  <DatabaseCollection>
    <MsSqlDatabase>
      <Name>sample</Name>
      <Active>true</Active>
      <Server>server.sample.domain</Server>
      <User>db_user</User>
      <Password>************</Password>
    </MsSqlDatabase>
  </DatabaseCollection>
```
## Tryby pracy
Aplikacja może pracować w dwóch trybach:
- **prosty (domyślny)** - aplikacja jest uruchamiana w trybie prostym, urchamiany jest pod web'a i serwera biznesowego oraz opcjonalnie webapi, webwcf, oraz scheduler'a. W trybie tym istnieje możliwość obsługi tylko jednej bazy danych na instancję aplikacji.
- **orkiestrowany** - aplikacja jest uruchamiana w trybie orkiestracji pod warunkiem obecności sekcji `appsettings.kubernetes.orchestrator`. Uruchamiany jest pod orchestratora, który na podstawie kompozycji w wyżej wymienionej sekcji powołuje odpowiednie komponenty aplikacji. W trybie tym możliwa jest obsługa wielu baz danych na instancję aplikacji.

## Tryb administracyjny
Poza trybami pracy aplikacja może być uruchomiona w trybie administracyjnym, który jest włączany poprzez ustawienie wartości `--set adminMode=true`. W tym trybie uruchamiany jest jedynie pod administracyjny, w którym można wykonywać operacje zarządzające aplikacją, np. za pomocą `dotnet dbmgr.dll`. Dostępne są odpowiednie zasoby backendowe (*appdata, localappdata, lista baz danych ...*).
```console
helm upgrade sample soneta/soneta -f values.yaml --install --set adminMode=true
```
## Tworzenie nowego środowiska demo

### Krok 1: Utworzenie bazy danych

Jeśli baza danych nie istnieje, należy utworzyć ją w trybie administracyjnym. W tym celu:

1. Ustaw pustą wartość dla zmiennej `dblist`
2. Uruchom aplikację w trybie `adminMode`
3. Połącz się z podem admin
4. Wykonaj polecenie utworzenia bazy:

```bash
dotnet dbmgr.dll create <NAZWA_BAZY> \
  --dbconfig ~/temp.xml \
  --mssql \
  --sqlserver <ADRES_SERWERA>,<PORT> \
  --sqldb <NAZWA_BAZY> \
  --sqluser <UŻYTKOWNIK> \
  --sqlpwd "<HASŁO>" \
  --demo gold \
  --active \
  --verbose \
  --recreate
```

### Krok 2: Aktualizacja konfiguracji Helm

Po pomyślnym utworzeniu bazy danych:

1. Skopiuj zawartość wygenerowanego pliku `temp.xml`
2. Wklej skopiowaną konfigurację do odpowiedniego pliku `values.yaml` w konfiguracji Helm

### Krok 3: Aktualizacja deploymentu

Wykonaj upgrade Helm z wyłączonym trybem administracyjnym:

```bash
helm upgrade   --set adminMode=false
```

Po wykonaniu tych kroków środowisko powinno być gotowe do użycia.


## Parametryzacja
Aplikacja jest parametryzowana poprzez plik/pliki z opcją -f, wartości w plikach `values.yaml` są łączone w jedną całość.
```console
helm upgrade sample soneta/soneta -f values1.yaml -f values2.yaml ... --install
```
Wartości można przekazywać również poprzez opcję `--set` jednak poza włączaniem trybu administracyjnego nie jest to zalecane, ponieważ staje się nieczytelne i trudne w utrzymaniu, a dodatkowo pliki mogą być wersjonowane w repozytorium i być przedmiotem audytu.

## Przykłady parametryzacji

- **Wskazanie wersji obrazu:**

```yaml
# values.yaml
image:
  tag: "2504.2.5"
dblist: |-
  <DatabaseCollection>...</DatabaseCollection>
```

- **Tryb orkiestratora z wieloma bazami danych:**

```yaml
# values.yaml
appsettings:
  orchestrator:
    kubernetes:
      composition:
        web:
          enabled: true
        server:
          enabled: true
dblist: |-
  <DatabaseCollection>
    <MsSqlDatabase>
      <Name>db1</Name>
      ...
    </MsSqlDatabase>
    <MsSqlDatabase>
      <Name>db2</Name>
      ...
    </MsSqlDatabase>
  </DatabaseCollection>
```

- **Nadpisanie zasobów dla serwera:**

```yaml
# values.yaml
resources:
  server:
    limits:
      cpu: 2
      memory: 2Gi
    requests:
      cpu: 100m
      memory: 500Mi
```

- **Ustawienie zmiennych środowiskowych:**

```yaml
# values.yaml
envs:
  # dla wszystkich komponentów
  all:
    # DOTNET_USE_POLLING_FILE_WATCHER - Ta zmienna środowiskowa, gdy ustawiona na "1", wymusza na platformie .NET używanie mechanizmu aktywnego sprawdzania zmian w plikach (polling) zamiast domyślnego mechanizmu powiadomień systemowych. Może to być przydatne w środowiskach, gdzie powiadomienia o zmianach plików nie działają poprawnie, np. w kontenerach lub na systemach plików sieciowych.
    - name: DOTNET_USE_POLLING_FILE_WATCHER
      value: "1"
    # TZ - Ta zmienna środowiskowa określa strefę czasową, w której działa aplikacja. Ustawienie jej na "Europe/Warsaw" powoduje, że wszystkie operacje związane z czasem będą wykonywane zgodnie z czasem lokalnym dla Polski.
    - name: TZ
      value: Europe/Warsaw
```
- **Ustawienie paramatrów domyślnego persistent volume claim:**

```yaml
resources:
  pvc:
    spec:
      resources:
        requests:
          storage: 250Mi
      # Wartość storageClassName jest opcjonalna, jeśli nie zostanie podana, domyślnie zostanie użyta storage class zdefiniowana w klastrze.
      # W przypadku Azure File Storage, można użyć storageClassName: azurefile
      storageClassName: azurefile
```

- **Ustawienie wolumenów:**

```yaml
# values.yaml
secrets:
- name: afs-secret
  data:
  - key: azurestorageaccountname
    value: your_account_name
  - key: azurestorageaccountkey
    value: your_account_key

volumes:
  all:
  # Podstawienie wolumenu dla wszystkich komponentów aplikacji, który będzie montowany w katalogu /home/app/.config/Soneta/Authentication i będzie zawierał plik z kluczami dla tokenów aplikacji
  - name: authentication
    mountPath: /home/app/.config/Soneta/Authentication
    subPath: tokenkey
    spec:
      csi:
        driver: file.csi.azure.com
        volumeAttributes:
          shareName: your_share_name
          secretName: afs-secret
```

- **Przykład parametryzacji ingress:**

```yaml
# values.yaml
# Przykład konfiguracji sekcji ingress, umożliwiającej wystawienie aplikacji na zewnątrz klastra z obsługą TLS oraz dodatkowymi adnotacjami dla kontrolera nginx.
ingress:
  enabled: true
  host: twoja.domena.pl
  tlsSecretName: ingress-tls  # Nazwa sekretu TLS do obsługi HTTPS
  annotations:
    nginx.ingress.kubernetes.io/client-body-buffer-size: "50m"  # Maksymalny rozmiar bufora ciała żądania
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"          # Maksymalny rozmiar żądania przesyłanego przez proxy
    nginx.ingress.kubernetes.io/proxy-buffer: "64k"             # Rozmiar bufora proxy
    nginx.ingress.kubernetes.io/proxy-buffer-size: "128k"       # Rozmiar pojedynczego bufora proxy
```
