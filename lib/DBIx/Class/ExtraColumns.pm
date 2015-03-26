package DBIx::Class::ExtraColumns;

use strict;
use warnings;

use parent qw(DBIx::Class);


our $VERSION = '0.01';


__PACKAGE__->mk_group_accessors(inherited  => qw(_extra_columns));


sub add_extra_columns {
	my ($self, @defs) = @_;

	my $cols = ($self->_extra_columns || $self->_extra_columns({}))->{ref($self) || $self} //= {};

	while (my $col = shift(@defs)) {
		my $info = ref($defs[0]) ? shift(@defs) : {};

		$info->{is_extra} = 1;
		$cols->{$col}     = $info;

		my $acc = $col;

		if (exists($info->{accessor})) {
			next unless defined($info->{accessor});
			$acc = [$info->{accessor}, $col];
		}
		$self->mk_group_accessors('extra_column' => $acc);
	}

	return $self;
}

sub add_extra_column { shift()->add_extra_columns(@_) }

sub get_extra_column {
	my ($self, $col) = @_;

	$self->throw_exception('Can\'t fetch data as class method')
		unless ref($self);

	my $info = $self->_find_extra_column($col);

	$self->throw_exception('No such extra-column "' . $col . '" on ' . ref($self))
		unless $info;

	my $ext = exists($info->{storage}) && $info->{storage} || 'data';

	if ($self->has_column_loaded($ext)) {
		my $data = $self->get_inflated_column($ext);

		return $data->{$col} if ref($data) eq 'HASH' && exists($data->{$col});
	}

	return undef;
}

sub set_extra_column {
	my ($self, $col, $val) = @_;

	$self->throw_exception('Can\'t store data as class method')
		unless ref($self);

	my $info = $self->_find_extra_column($col);

	$self->throw_exception('No such extra-column "' . $col . '" on ' . ref($self))
		unless $info;

	my $ext = exists($info->{storage}) && $info->{storage} || 'data';

	$self->throw_exception('Extra-column storage "' . $ext . '" not loaded')
		if $self->in_storage && !$self->has_column_loaded($ext);

	my $data = $self->get_inflated_column($ext);

	if (defined($data)) {
		$self->throw_exception('Extra-column storage value is not hash ref')
			unless ref($data) eq 'HASH';
	}
	else {
		$data = {};
	}

	if (exists($data->{$col})) {
		unless (defined($val)) {
			delete($data->{$col});
		}
		else {
			return $val if defined($data->{$col}) && $data->{$col} eq $val;
			$data->{$col} = $val;
		}
	}
	else {
		return undef unless defined($val);
		$data->{$col} = $val;
	}

	$self->set_inflated_column($ext, $data);

	return $val;
}

sub column_info {
	my ($self, $col) = @_;

	my $info = $self->_find_extra_column($col);

	return $info if $info;
	return $self->next::method($col);
}

sub columns_info {
	my ($self, $cols) = @_;

	my %ret;

	if ($cols && @$cols) {
		my @cols;

		for (@$cols) {
			my $info = $self->_find_extra_column($_);

			push(@cols, $_) and next unless $info;
			$ret{$_} = $info;
		}
		%ret = (%ret, %{$self->next::method(\@cols)}) if @cols;
	}
	else {
		%ret = (%{$self->_extra_columns_info}, %{$self->next::method()});
	}

	return \%ret;
}

sub extra_columns {
	my ($self) = @_;

	my $cols = $self->_extra_columns || $self->_extra_columns({});
	my %ret;

	for (keys(%$cols)) {
		next unless $self->isa($_);
		$ret{$_} = 1 for keys(%{$cols->{$_}});
	}

	return keys(%ret);
}

sub _find_extra_column {
	my ($self, $col) = @_;

	my $cols = $self->_extra_columns || $self->_extra_columns({});

	for (keys(%$cols)) {
		next unless $self->isa($_);
		return $cols->{$_}{$col} if exists($cols->{$_}{$col});
	}

	return;
}

sub _extra_columns_info {
	my ($self) = @_;

	my $cols = $self->_extra_columns || $self->_extra_columns({});
	my %ret;

	for (keys(%$cols)) {
		next unless $self->isa($_);
		%ret = (%{$cols->{$_}}, %ret);
	}

	return \%ret;
}


eval {
	require DBIx::Class::Candy::Exports;

	DBIx::Class::Candy::Exports::export_methods(['add_extra_column']);
	DBIx::Class::Candy::Exports::export_method_aliases({extra_column => 'add_extra_column'});
};


1;

__END__

=encoding utf8

=head1 NAME

DBIx::Class::ExtraColumns - Virtual columns that stores inside another column

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

L<DBIx::Class>, L<DBIx::Class::FrozenColumns>, L<DBIx::Class::VirtualColumns>.

=head1 AUTHOR

Denis Ibaev, C<dionys@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015, Denis Ibaev.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

See http://dev.perl.org/licenses/ for more information.

=cut
