from flask import Flask, render_template, request, url_for, redirect
import cx_Oracle
import config

app = Flask(__name__)
cx_Oracle.init_oracle_client(lib_dir=r"C:\Users\acuco\AppData\Local\Microsoft\WindowsApps\instantclient_21_3")
dsn = cx_Oracle.makedsn("bd-dc.cs.tuiasi.ro", 1539, service_name="orcl")
connection = cx_Oracle.connect(
    user=config.username,
    password=config.password,
    dsn=dsn)


@app.route('/')
@app.route('/Home')
def showHome():
    return render_template('Home.html')


@app.route('/')
@app.route('/Librarie')
def showLibrarie():
    library = {}
    c = connection.cursor()
    c.execute('select * from librarie')
    for result in c:
        library = {'librarie_id': result[0],
                   'adresa': result[1],
                   'telefon': result[2],
                   'email': result[3]}
    c.close()
    return render_template('Librarie.html', library=library)


@app.route('/')
@app.route('/Clienti')
def showClienti():
    clienti = []
    c = connection.cursor()
    c.execute('select * from client order by client_id desc')
    for result in c:
        client = {'client_id': result[0],
                  'nume_client': result[1],
                  'cnp_client': result[2],
                  'nr_card': result[3],
                  'telefon': result[4],
                  'adresa': result[5],
                  'card_fidelitate': result[6]}
        clienti.append(client)
    c.execute("select client_id, to_char(sysdate, 'YYYY') - case when substr(cnp_client, 2, 2) > 21 then "
              "19||''||substr( "
              "cnp_client, 2, 2) else 20||''||substr(cnp_client, 2, 2) end from client")
    info = []
    for r in c:
        i = {'id': r[0],
             'age': r[1]
             }
        info.append(i)
    return render_template('Clienti.html', clienti=clienti, info=info)


def getFurnizori():
    furnizori = []
    c = connection.cursor()
    c.execute('select * from furnizori order by furnizor_id asc')
    for result in c:
        furnizor = {'furnizor_id': result[0],
                    'nume_furnizor': result[1],
                    'adresa': result[2],
                    'email': result[3]}
        furnizori.append(furnizor)
    c.close()
    return furnizori


@app.route('/')
@app.route('/Furnizori', methods=['GET', 'POST'])
def showFurnizori():
    furnizori = getFurnizori()
    c = connection.cursor()
    if request.method == 'POST':
        if 'Update' in request.form['change']:
            return redirect(url_for('updateFurnizor'))
        elif 'Delete' in request.form['change']:
            return redirect(url_for('deleteFurnizor'))
        elif 'Undo' in request.form['change']:
            c.execute('rollback')
            c.execute('commit')
            return render_template('Furnizori.html', furnizori=furnizori)
    else:
        return render_template('Furnizori.html', furnizori=furnizori)


@app.route('/')
@app.route('/AddFurnizor', methods=['GET', 'POST'])
def addFurnizor():
    if request.method == 'POST':
        c = connection.cursor()
        name = "'" + request.form['nume_furnizor'] + "'"
        adresa = "'" + request.form['adresa'] + "'"
        email = "'" + request.form['email'] + "'"
        c.execute("insert into furnizori(nume_furnizor, adresa, email) values(%s, %s, "
                  "%s)" % (name, adresa, email))
        c.close()
        return redirect(url_for('showFurnizori'))
    else:
        return render_template('AddFurnizor.html')


@app.route('/')
@app.route('/Undo/<pointu>/<pointd>/<destination>', methods=['GET', 'POST'])
def undo(pointu, pointd, destination):
    c = connection.cursor()
    types = ['update', 'delete']
    if request.method == 'POST':
        if 'update' in request.form['change']:
            c.execute('rollback to savepoint ' + pointu)
            c.execute('commit')
        elif 'delete' in request.form['change']:
            c.execute('rollback to savepoint ' + pointd)
            c.execute('commit')
        return redirect(url_for(destination))
    else:
        return render_template('Undo.html', types=types)


@app.route('/')
@app.route('/UpdateFurnizor', methods=['GET', 'POST'])
def updateFurnizor():
    c = connection.cursor()
    furnizori = getFurnizori()
    types = ['adresa', 'email']

    if request.method == 'POST':
        furn_id = "'" + (request.form['furnizor'])[1] + "" + (request.form['furnizor'])[2] + "" + \
                  (request.form['furnizor'])[3] + "'"
        result = "'" + request.form['valoare'] + "'"
        if 'adresa' in request.form['update']:
            c.execute('update furnizori set adresa=' + result + ' where furnizor_id=' + furn_id)
        elif 'email' in request.form['update']:
            c.execute('update furnizori set email=' + result + ' where furnizor_id=' + furn_id)
        return redirect(url_for('showFurnizori'))
    else:
        return render_template('UpdateFurnizor.html', furnizori=furnizori, types=types)


@app.route('/')
@app.route('/DeleteFurnizor', methods=['GET', 'POST'])
def deleteFurnizor():
    furnizori = getFurnizori()
    c = connection.cursor()
    if request.method == 'POST':
        number = "'" + request.form['furnizor'][1] + "" + request.form['furnizor'][2] + "" + request.form['furnizor'][
            3] + "'"
        c.execute('select vanzare_nr_bon from detalii_vanzare where produse_produs_id in (select produs_id from '
                  'produse where furnizor_id =' + number + ")")
        bonuri = []
        for res in c:
            bon = "'" + str(res[0]) + "'"
            bonuri.append(bon)

        for bon in bonuri:
            c.execute('delete from detalii_vanzare where vanzare_nr_bon=' + bon)
            c.execute('delete from vanzare where nr_bon=' + bon)

        c.execute('delete from produse where furnizor_id=' + number)
        c.execute('delete from furnizori where furnizor_id=' + number)
        return redirect(url_for('showFurnizori'))
    else:
        return render_template('DeleteFurnizor.html', furnizori=furnizori)


def getProduse():
    products = []
    c = connection.cursor()
    c.execute('select * from produse order by produs_id asc')
    for result in c:
        product = {'produs_id': result[0],
                   'nume_produs': result[1],
                   'pret': result[2],
                   'cantitate_disponibila': result[3],
                   'furnizor_id': result[4]}
        products.append(product)
    return products


@app.route('/')
@app.route('/Produse', methods=['GET', 'POST'])
def showProduse():
    products = getProduse()
    furnizori = getFurnizori()
    c = connection.cursor()
    if request.method == 'POST':
        if 'Delete produs' in request.form['change']:
            return redirect(url_for('deleteProdus'))
        elif 'undo' in request.form['change']:
            c.execute('rollback')
            c.execute('commit')
            return render_template('Produse.html', products=products, furnizori=furnizori)
        elif 'Update' in request.form['change']:
            return redirect(url_for('updateProdus'))
    else:
        return render_template('Produse.html', products=products, furnizori=furnizori)


@app.route('/')
@app.route('/AddProdus', methods=['GET', 'POST'])
def addProdus():
    furnizori = getFurnizori()
    if request.method == 'POST':
        c = connection.cursor()
        name = "'" + request.form['nume_produs'] + "'"
        price = "'" + request.form['pret'] + "'"
        quantity = "'" + request.form['cantitate'] + "'"
        furnizor = "'" + request.form['id_furn'][0] + "" + request.form['id_furn'][1] + "" + request.form['id_furn'][
            2] + "'"
        c.execute("insert into produse(nume_produs, pret, cantitate_disponibila, furnizor_id)  values(%s, "
                  "%s , %s, %s)" % (name, price, quantity, furnizor))
        c.execute('commit')
        c.close()
        return redirect(url_for('showProduse'))
    else:
        return render_template('AddProdus.html', furnizori=furnizori)


@app.route('/')
@app.route('/UpdateProdus', methods=['GET', 'POST'])
def updateProdus():
    c = connection.cursor()
    products = getProduse()
    types = ['nume', 'pret', 'stoc']
    if request.method == 'POST':
        product_id = "'" + request.form['produs'][1] + "" + request.form['produs'][2] + "" + request.form['produs'][
            3] + "'"
        result = "'" + request.form['valoare'] + "'"
        if 'nume' in request.form['update']:
            c.execute('update produse set nume_produs=' + result + ' where produs_id=' + product_id)
        elif 'pret' in request.form['update']:
            c.execute('update produse set pret=' + result + ' where produs_id=' + product_id)
        elif 'stoc' in request.form['update']:
            c.execute('update produse set cantitate_disponibila=' + result + ' where produs_id=' + product_id)
        return redirect(url_for('showProduse'))
    else:
        return render_template('UpdateProdus.html', products=products, types=types)


@app.route('/')
@app.route('/DeleteProdus', methods=['GET', 'POST'])
def deleteProdus():
    products = getProduse()
    c = connection.cursor()
    if request.method == 'POST':
        number = "'" + request.form['produs'][1] + "" + request.form['produs'][2] + "" + request.form['produs'][3] + "'"
        c.execute('select vanzare_nr_bon from detalii_vanzare where produse_produs_id=' + number)
        bonuri = []
        for r in c:
            bon = "'" + str(r[0]) + "'"
            bonuri.append(bon)
        for bon in bonuri:
            c.execute('delete from detalii_vanzare where vanzare_nr_bon=' + bon)
            c.execute('delete from vanzare where nr_bon=' + bon)
        c.execute('delete from produse where produs_id=' + number)
        return redirect(url_for('showProduse'))
    else:
        return render_template('DeleteProdus.html', products=products)


@app.route('/')
@app.route('/Vanzare', methods=['GET', 'POST'])
def addVanzari():
    angajati = getAngajati()
    c = connection.cursor()
    if request.method == 'POST':
        name = "'" + request.form['nume'] + "'"
        cnp = "'" + request.form['cnp'] + "'"
        nr_card = "'" + request.form['card'] + "'"
        phone = "'" + request.form['telefon'] + "'"
        adresa = "'" + request.form['adresa'] + "'"
        cardf = "'" + request.form['card_f'] + "'"
        c.execute("insert into client(nume_client, cnp_client, nr_card, telefon, adresa, card_fidelitate) values("
                  "%s, %s, %s, %s, %s, %s)" % (name, cnp, nr_card, phone, adresa, cardf))
        c.execute('commit')

        data = "'" + request.form['dt'] + "'"
        ida = "'" + request.form['id_emp'][0] + "" + request.form['id_emp'][1] + "'"
        c.execute('select client_client_id_seq.currval from DUAL')
        res = c.fetchone()
        idc = res[0]
        c.execute("insert into vanzare(data, angajat_id, client_id, nr_card) values(to_date(%s, "
                  "'dd-mm-yyyy'), %s, "
                  "%s, %s)" % (data, ida, idc, nr_card))
        c.execute('select vanzare_nr_bon_seq.currval from DUAL')
        res = c.fetchone()
        nr_bon = res[0]
        c.close()
        return redirect(url_for('addProductsToCart', bon=nr_bon))
    else:
        return render_template('Vanzare.html', angajati=angajati)


@app.route('/')
@app.route('/Cos', methods=['GET', 'POST'])
def addProductsToCart():
    products = getProduse()
    c = connection.cursor()
    c.execute('select vanzare_nr_bon_seq.currval from DUAL')
    res = c.fetchone()
    bon = res[0]
    if request.method == 'POST':
        if 'add' in request.form['submit']:
            c = connection.cursor()
            product_id = "'" + (request.form['produs'])[1] + "" + (request.form['produs'])[2] + "" + \
                         (request.form['produs'])[3] + "'"
            quantity = "'" + request.form['cant'] + "'"
            c.execute(
                "insert into detalii_vanzare(produse_produs_id, vanzare_nr_bon, cantitate_cumparata) "
                "values(%s, "
                "vanzare_nr_bon_seq.CURRVAL, %s)" %
                (product_id, quantity))
            c.execute('commit')
            return render_template('Cos.html', products=products)
        elif 'pay' in request.form['submit']:
            return redirect(url_for('detalii_vanzare', nr_bon=bon))

    else:
        return render_template('Cos.html', products=products)


@app.route('/')
@app.route('/<nr_bon>')
def detalii_vanzare(nr_bon):
    c = connection.cursor()
    c.execute("select * from detalii_vanzare where vanzare_nr_bon=" + nr_bon)
    details = []
    for res in c:
        detail = {
            'produse_produs_id': res[0],
            'vanzare_nr_bon': res[1],
            'cantitate_cumparata': res[2],
            'pret_final': res[3]
        }
        details.append(detail)
    c.execute("select vanzare_nr_bon, sum(pret_final) from detalii_vanzare group by vanzare_nr_bon having "
              "vanzare_nr_bon = " + nr_bon)
    res = c.fetchone()
    price = res[1]
    c.execute("select produs_id, nume_produs, pret from produse where produs_id in (select produse_produs_id from "
              "detalii_vanzare where "
              "vanzare_nr_bon=" + nr_bon + ")")
    products = []
    for r1 in c:
        product = {'id': r1[0],
                   'name': r1[1],
                   'pret': r1[2]}
        products.append(product)

    for product in products:
        for detail in details:
            if detail['produse_produs_id'] == product['id']:
                product['pret'] = product['pret'] * detail['cantitate_cumparata']
    nr_bon = nr_bon.replace("'", "")

    c.execute("select nr_bon, c.client_id, card_fidelitate, data from client c join vanzare v on (c.client_id = "
              "v.client_id) where c.client_id=(select client_id from vanzare where nr_bon=" + nr_bon + ")")
    clients = []
    for r in c:
        client = {
            'bon': str(r[0]),
            'id': "'" + str(r[1]) + "'",
            'card': r[2],
            'data': "'" + str(r[3]) + "'"
        }
        clients.append(client)

    for client in clients:
        a = client['data']
        d = (a.split(' ')[0]).split('-')
        client['data'] = d[1] + "-" + d[2]
        if client['card'] is None:
            client['card'] = 0

    return render_template('Detalii vanzare.html', details=details, price=price,
                           products=products, bon=nr_bon, clients=clients)


@app.route('/')
@app.route('/SaleHistory', methods=['GET', 'POST'])
def showVanzari():
    c = connection.cursor()
    vanzari = []
    c.execute("select * from vanzare order by data desc")
    for result in c:
        data = result[1].date()
        vanzare = {'nr_bon': result[0],
                   'data': data,
                   'angajat_id': result[2],
                   'client_id': result[3],
                   'nr_card': result[4]
                   }
        vanzari.append(vanzare)
    if request.method == 'POST':
        nr_bon = "'" + request.form['sale'] + "'"
        return redirect(url_for('detalii_vanzare', nr_bon=nr_bon))
    else:
        return render_template('SaleHistory.html', vanzari=vanzari)


def getAngajati():
    angajati = []
    c = connection.cursor()
    c.execute('select * from angajat order by angajat_id desc')
    for result in c:
        angajat = {'angajat_id': result[0], 'librarie_id': result[1], 'nume_angajat': result[2]}
        angajati.append(angajat)
    return angajati


@app.route('/')
@app.route('/Angajati', methods=['GET', 'POST'])
def showAngajati():
    angajati = getAngajati()
    if request.method == 'POST':
        if 'undo' in request.form['emp']:
            return redirect(url_for('undo', pointu='udpA', pointd='delA', destination='showAngajati'))
        else:
            id = request.form['emp']
            return redirect(url_for('angajat_details', emp_id=id))
    else:
        return render_template('Angajati.html', angajati=angajati)


@app.route('/')
@app.route('/AddAngajat', methods=['GET', 'POST'])
def addAngajat():
    c = connection.cursor()
    if request.method == 'POST':
        name = "'" + request.form['nume'] + "'"
        c.execute("insert into angajat(librarie_id, nume_angajat) values(100, %s)" % name)
        cnp = "'" + request.form['cnp'] + "'"
        adresa = "'" + request.form['adresa'] + "'"
        phone = "'" + request.form['telefon'] + "'"
        email = "'" + request.form['email'] + "'"

        c.execute("insert into detalii_angajat values(angajat_angajat_id_seq.CURRVAL, %s, %s, "
                  "%s, %s)" % (cnp, adresa, phone, email))
        c.execute('commit')
        return redirect(url_for('showAngajati'))
    else:
        return render_template('AddAngajat.html')


@app.route('/')
@app.route('/Angajati Detalii/<emp_id>', methods=['GET', 'POST'])
def angajat_details(emp_id):
    c = connection.cursor()
    id = "'" + emp_id + "'"
    c.execute('select * from detalii_angajat where angajat_id=' + id)
    res = c.fetchone()
    details = {
        'cnp_angajat': res[1],
        'adresa': res[2],
        'telefon': res[3],
        'email': res[4]
    }
    if request.method == 'POST':
        if 'Update' in request.form['change']:
            return redirect(url_for('updateEmployee', emp_id=emp_id))
        elif 'Delete' in request.form['change']:
            c.execute('commit')
            c.execute('savepoint delA')
            c.execute('delete from detalii_vanzare where vanzare_nr_bon in '
                      '(select nr_bon from vanzare where angajat_id=' + id + ')')
            c.execute('delete from vanzare where angajat_id=' + id)
            c.execute('delete from detalii_angajat where angajat_id=' + id)
            c.execute('delete from angajat where angajat_id=' + id)
            return redirect(url_for('showAngajati'))

    else:
        c.execute("select to_char(sysdate, 'YYYY') - case when substr(cnp_angajat, 2, 2) > 21 then 19||''||substr("
                  "cnp_angajat, 2, 2) else 20||''||substr(cnp_angajat, 2, 2) end from detalii_angajat where angajat_id=" + emp_id)
        age = c.fetchone()[0]
        return render_template('Angajati Detalii.html', details=details, emp_id=emp_id, age=age)


@app.route('/')
@app.route('/UpdateAngajat/<emp_id>', methods=['GET', 'POST'])
def updateEmployee(emp_id):
    c = connection.cursor()
    types = ['adresa', 'telefon', 'email']
    id = "'" + emp_id + "'"
    if request.method == 'POST':
        result = "'" + request.form['valoare'] + "'"
        c.execute('commit')
        c.execute('savepoint updA')
        if 'adresa' in request.form['update']:
            c.execute('update detalii_angajat set adresa=' + result + ' where angajat_id=' + id)
        elif 'telefon' in request.form['update']:
            c.execute('update detalii_angajat set telefon=' + result + ' where angajat_id=' + id)
        elif 'email' in request.form['update']:
            c.execute('update detalii_angajat set email=' + result + ' where angajat_id=' + id)
        return redirect(url_for('angajat_details', emp_id=emp_id))
    else:
        return render_template('UpdateAngajat.html', types=types)


if __name__ == '__main__':
    app.run(debug=True)
    connection.close()
