requires 'perl', '5.008001';
requires 'Stream::Buffered';
requires 'Module::load';
requires 'JSON' => '2';
requires 'Encode';
requires 'HTTP::MultiPartParser';
requires 'HTTP::Message' => 6;
requires 'File::Temp';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Hash::MultiValue';
    requires 'File::Spec::Functions';
    requires 'Cwd';
};


