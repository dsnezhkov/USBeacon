from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.types import DateTime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///beacons.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app)

class Beacon(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True, nullable=False)
    hashid = db.Column(db.String(8))
    app = db.Column(db.String(2))
    ip = db.Column(db.String(16))
    data = db.Column(db.Text(512))
    created_at = db.Column(DateTime(True))

    def __init__(self, hashid, app, ip, data, created_at):
        self.hashid = hashid
        self.app = app
        self.ip = ip
        self.data = data
        self.created_at = created_at

    def __repr__(self):
        return '<Beacon: [hashid=%s, app=%s, ip=%s, data=%s] @ %s>' % (self.hashid,
self.app, self.ip, self.data, self.created_at.strftime("%B %d %Y - %I:%M%p"))
