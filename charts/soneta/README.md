# Soneta Kubernetes Helm Chart

> **Wersja 0.7.0-alpha.2 (alfa).** Zmienne środowiskowe (`envs`), wolumeny (`volumes`), argumenty (`args`), sekrety (`secrets`), dodatkowe PVC (`pvcs`) i tolerancje (`tolerations`) można podawać jako mapy (zalecane); listy są nadal obsługiwane, ale są przestarzałe.

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

### Warstwy: `all` -> `frontend`/`backend` -> komponent

Wartości `envs`, `volumes` i `args` są składane w poziomach: `all`, następnie `frontend` lub `backend` (zależnie od komponentu), a na końcu nazwa komponentu (np. `server`). Późniejszy poziom nadpisuje element o tym samym kluczu.

- Element w mapie **zastępuje** element o tym samym kluczu z wcześniejszego poziomu (lub z listy, dopasowanej po `name`).
- `null` **usuwa** element odziedziczony z wcześniejszego poziomu.
- Nowe klucze są dodawane na końcu, w kolejności posortowanej po kluczu.
- Dla `volumes` nadpisanie jest płytkie: `name`, `mountPath`, `subPath` i `spec` są zastępowane osobno; `spec` nie jest scalany wgłąb.

Ponieważ Helm zastępuje listy w całości, pliki można łączyć np. tak:

```console
helm upgrade sample soneta/soneta -f values.yaml -f values-prod.yaml --install
```

```yaml
# values-prod.yaml
envs:
  all:
    TZ: UTC              # zmienia wartość z values.yaml
    DEBUG_MODE: null     # usuwa zmienną odziedziczoną z values.yaml
```

### Migracja z list

Listy są nadal przyjmowane (**przestarzałe**) i renderują się identycznie jak dotąd. Zalecany zapis to mapa kluczowana nazwą elementu:

| Lista (przestarzała) | Mapa (zalecana) |
|---|---|
| `envs.all: [{name: TZ, value: Europe/Warsaw}]` | `envs.all: {TZ: Europe/Warsaw}` |
| `envs.server: [{name: X, valueFrom: {...}}]` | `envs.server: {X: {valueFrom: {...}}}` |
| `volumes.all: [{name: a, mountPath: /a, spec: {...}}]` | `volumes.all: {a: {mountPath: /a, spec: {...}}}` |
| `volumes.all: [{mountPath: /m}]` (bez nazwy) | `volumes.all: {m: {mountPath: /m}}` |
| `args.web: ["--urls", "http://*:8080"]` | `args.web: {10-urls: ["--urls", "http://*:8080"]}` |
| `secrets: [{name: afs, data: [{key: k, value: v}]}]` | `secrets: {afs: {data: {k: v}}}` |
| `pvcs: [{name: extra, spec: {...}}]` | `pvcs: {extra: {spec: {...}}}` |
| `tolerations: [{key: gpu, operator: Exists, effect: NoSchedule}]` | `tolerations: {gpu: {key: gpu, operator: Exists, effect: NoSchedule}}` (klucz to dowolny identyfikator) |
| `nodeSelector: {disktype: ssd}` | bez zmian (mapa; domyślnie `{}`) |

Uwagi:
- Przy zamianie listy na mapę **kolejność zmiennych środowiskowych zmienia się** (klucze są sortowane). Pody zostaną więc zrestartowane jednorazowo przy aktualizacji.
- Wartość `$(VAR)` rozwija się tylko do zmiennych zdefiniowanych **wcześniej** na liście env.
- Lista na bazie i mapa w **tym samym** poziomie: mapa zastępuje listę w całości (zachowanie Helm). Mapa na **innym** poziomie upsertuje i usuwa elementy listy po nazwie.
- Chart wypisuje w NOTES ostrzeżenie, gdy wykryje niepuste listy (`envs`, `volumes`, `args`, `secrets`, `pvcs`, `tolerations`).
- `secrets`, `pvcs` i `tolerations` nie mają warstw: mapa w pliku `-f` nadpisuje pojedynczy element, a `null` go usuwa. Elementy są renderowane w kolejności kluczy (dla `tolerations` identyfikator to dowolny klucz mapy).
- `nodeSelector` jest mapą etykiet (`{klucz: wartość}`); pusta lista `[]` jest nadal akceptowana. Od 0.7.0-alpha.2 pody renderują tylko etykiety (wcześniej przez błąd renderowany był cały obiekt `values`).

### Przykłady `--set`

```console
helm upgrade sample soneta/soneta -f values.yaml --set envs.all.TZ=UTC
helm upgrade sample soneta/soneta -f values.yaml --set 'envs.all.My\.Key=wartosc'
helm upgrade sample soneta/soneta -f values.yaml --set envs.server.TZ=null
helm upgrade sample soneta/soneta -f values.yaml --set-json 'envs.web.SECRET={"valueFrom":{"secretKeyRef":{"name":"my-secret","key":"password"}}}'
```
- `My\.Key` to klucz zawierający kropkę (w powłoce `\.` przekazuje `\.` do Helm).
- `null` usuwa zmienną odziedziczoną z wcześniejszego poziomu.
- `--set-json` służy do wartości złożonych (np. `valueFrom`).
- Uwaga: `--set envs.server.X=...` na liście ustawionej w pliku `-f` zastępuje całą listę (zob. wyżej).

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

Szczegółowa dokumentacja dotycząca konfiguracji kompozycji, jest analogiczna jak w przypadku orchestratora procesowego i znajduje się bazie wiedzy pod adresem: https://dok.enova.pl/wdrozenia/konfiguracja-orkiestratora,5678

```yaml
# values.yaml
appsettings:
  orchestrator:
    kubernetes:
      composition:
        router:
          enabled: true
          #inprocess: true  # odkomentować, aby uruchomić w podzie orchestratora
        commhub:
          enabled: true
          #inprocess: true  # odkomentować, aby uruchomić w podzie orchestratora
        dashboard:
          enabled: true
        web:
          enabled: true
          #replicas: 2  # odkomentować, aby ustawić liczbę replik web'a
        webapi:
          enabled: true
          #replicas: 2  # odkomentować, aby ustawić liczbę replik webapi
        server:
          enabled: true
          #maxDynamicRuns: 3 # odkomentować, aby ustawić maksymalną liczbę dynamicznych uruchomień serwera
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

- **Aspire Dashboard zarządzany przez orkiestrator (internal):**

```yaml
# values.yaml
appsettings:
  orchestrator:
    kubernetes:
      composition:
        dashboard:
          enabled: true

# domyślny obraz dashboardu
image:
  dashboard: mcr.microsoft.com/dotnet/aspire-dashboard:13
```

Po włączeniu komponentu `dashboard` chart:
- publikuje komponent dashboard jako szablon orkiestratora,
- ustawia wewnętrzny (unsecured) tryb połączenia z resource service orkiestratora,
- udostępnia porty usługi dashboard:
  - `80` (UI, target `18888`),
  - `4317` (OTLP/gRPC, target `18889`),
  - `4318` (OTLP/HTTP, target `18890`),
- ustawia dla pozostałych komponentów eksport telemetryczny OTLP na `http://<release>-soneta-dashboard:4317`.

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
    # DOTNET_USE_POLLING_FILE_WATCHER - Ta zmienna środowiskowa, gdy ustawiona na "1", wymusza na platformie .NET używanie mechanizmu aktywnego sprawdzania zmian w plikach (polling) zamiast domyślnego mechanizmu powiadomień systemowych.
    DOTNET_USE_POLLING_FILE_WATCHER: "1"
    # TZ - strefa czasowa, w której działa aplikacja
    TZ: Europe/Warsaw
  server:
    # wartość z sekretu zamiast wpisanej na sztywno (pole valueFrom zamiast value)
    SOME_SECRET:
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: password
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

- **Ustawienie sekretów, tolerancji i dodatkowych PVC:**

```yaml
# values.yaml
secrets:
  afs-secret:
    data:
      azurestorageaccountname: your_account_name
      azurestorageaccountkey: your_account_key
tolerations:
  gpu:
    key: gpu
    operator: Exists
    effect: NoSchedule
nodeSelector:
  disktype: ssd
pvcs:
  extra:
    spec:
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 1Gi
```

- **Ustawienie wolumenów:**

```yaml
# values.yaml

volumes:
  all:
    # Wolumen dla wszystkich komponentów aplikacji, montowany w katalogu /home/app/.config/Soneta/Authentication (klucz to nazwa wolumenu, bo jest podane `spec`)
    authentication:
      mountPath: /home/app/.config/Soneta/Authentication
      subPath: tokenkey
      spec:
        csi:
          driver: file.csi.azure.com
          volumeAttributes:
            shareName: your_share_name
            secretName: afs-secret
    # Samo montowanie (bez `spec`) na domyślnym wolumenie PVC; skrót: wartość to ścieżka
    logs: /home/app/logs
```

- **Ustawienie argumentów uruchomieniowych:**

```yaml
args:
  web:
    10-urls: ["--urls", "http://*:8080"]
  server:
    20-verbose: --verbose
```
Klucze są sortowane w obrębie poziomu. Argumenty dla Aspire Dashboard czytane są wyłącznie z `args.dashboard`.

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

- **Ustawienie health checków (probe'ów):**

```yaml
# values.yaml
# Przykład nadpisania ustawień probe'ów (all -> frontend/backend -> komponent), handler ustala paczka.
healthcheck:
  # enabled: false  # Wyłączenie wszystkich probe'ów
  all:
    liveness:
      failureThreshold: 5    # Liczba nieudanych prób, po której kontener jest restartowany
  backend:
    startup:
      failureThreshold: 30   # Więcej czasu na start serwera (30 x 5 s)
  web:
    readiness:
      enabled: true          # Włączenie readiness probe, np. przy wielu replikach
  scheduler:
    enabled: false           # Wyłączenie probe'ów dla komponentu
```
