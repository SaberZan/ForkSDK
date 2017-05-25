from setuptools import setup, find_packages


setup(
	name='pycrypto',
    author='dlitz',
    description='Python Cryptography Toolkit',
    url="https://github.com/dlitz/pycrypto",
    version='2.1.0',
    license='BSD License',
    install_requires = ['openstep_parser'],
    packages=find_packages()
 )